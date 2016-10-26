SoundControl = class("SoundControl")
SoundControl.instance = nil

function SoundControl.getInstance()
	if not SoundControl.instance then
		SoundControl.instance = SoundControl.new()
	end
	return SoundControl.instance
end

function SoundControl:ctor()
	
end

function SoundControl:setEffectVolume(val)
	AudioEngine.setEffectsVolume(val)
end

function SoundControl:setMusicVolume(val)
	AudioEngine.setMusicVolume(val)
end

--播放音乐--
function SoundControl:playMusicByKey(key, repeats)
	AudioEngine.playMusic(sound_manager[key], repeats or true)
end

function SoundControl:playMusicByFile(file, repeats)
	AudioEngine.playMusic(file, repeats or true)
end

--暂停音乐--
function SoundControl:pauseMusic()
	AudioEngine.pauseMusic()
end
-- 继续播放音乐  
function SoundControl:resumeMusic()
	AudioEngine.resumeMusic() 
end
--停止音乐--
function SoundControl:stopMusics()
	AudioEngine.stopMusic()
end

-- --加减音乐音量--
-- function SoundControl:setMusicVolumes(_float)
-- 	AudioEngine.setMusicVolume(AudioEngine.getMusicVolume() + _float)
-- end

----------------------------------------------------------------------


--播放音效--
function SoundControl:playEffectByKey(key, repeats)
	AudioEngine.playEffect(sound_manager[key], repeats or false)
end

function SoundControl:playEffectByFile(file, repeats)
	AudioEngine.playEffect(file, repeats or false)
end

--停止音效--
function SoundControl:stopEffects(_nSoundId)
	if _nSoundId then
		AudioEngine.stopEffect(_nSoundId)
	end
end

--暂停音效--
function SoundControl:pauseEeffects(_nSoundId)
	if _nSoundId then
		AudioEngine.pauseEffect(_nSoundId)
	end
end
--暂停所有音效--
function SoundControl:pauseAllEffects()
	AudioEngine.pauseAllEffects()
end
--加减音乐音量--
function SoundControl:setEffectVolumes(_float)
	AudioEngine.setEffectsVolume(AudioEngine.getEffectsVolume() + _float)
end

--停止所有音效--
function  SoundControl:stopAllEffects()
	AudioEngine.stopAllEffects()
end
-- -- 恢复音效
-- function GameSound:resumeEffects(_nSoundId)
-- 	AudioEngine.resumeEffect(_nSoundId) 
-- end
--恢复所有音效
function SoundControl:resumeAllEffects()
	AudioEngine.resumeAllEffects()
end