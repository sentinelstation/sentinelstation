﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;
using System.IO;
using System;

//[InitializeOnLoad]
[CreateAssetMenu(fileName = "ClothingData", menuName = "ScriptableObjects/ClothingData", order = 1)]
public class ClothingData : BaseClothData
{
	public EquippedData Base; //Your Basic clothing, If any missing data on any of the other points it will take it from here
	public EquippedData Base_Adjusted; //Variant for if it is Worn differently
	public EquippedData DressVariant; //humm yeah Dresses
	public List<EquippedData> Variants; //For when you have 1 million colour variants

	public override Sprite SpawnerIcon()
	{
		return Base.ItemIcon.Sprites[0];
	}

	public override void  InitializePool()
	{
		if (Spawn.ClothingStoredData.ContainsKey(this.name) && Spawn.ClothingStoredData[this.name] != this)
		{
			Logger.LogError("a ClothingData Has the same name as another one name " + this.name + " Please rename one of them to a different name");
		}
		Spawn.ClothingStoredData[this.name] = this;
	}

	public static void getClothingDatas(List<ClothingData> DataPCD)
	{
		DataPCD.Clear();
		var PCD = Resources.LoadAll<ClothingData>("textures/clothing");
		foreach (var PCDObj in PCD)
		{
			DataPCD.Add(PCDObj);
		}
	}

	private static void loadFolder(string folderpath, List<ClothingData> DataPCD)
	{
		folderpath = folderpath.Substring(folderpath.IndexOf("Resources", StringComparison.Ordinal) + "Resources".Length);
		foreach (var PCDObj in Resources.LoadAll<ClothingData>(folderpath))
		{
			if (!DataPCD.Contains(PCDObj))
			{
				DataPCD.Add(PCDObj);
			}
		}
	}

	public override string ToString()
	{
		return $"{name}";
	}


}

[System.Serializable]
public class EquippedData
{
	public SpriteSheetAndData Equipped;
	public SpriteSheetAndData InHandsLeft;
	public SpriteSheetAndData InHandsRight;
	public SpriteSheetAndData ItemIcon;
}