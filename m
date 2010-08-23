From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
Date: Mon, 23 Aug 2010 15:43:12 +0800
Message-ID: <4C722690.6070209@cn.fujitsu.com>
References: <4C592F85.8070308@cn.fujitsu.com>	 <4C59306A.9090302@cn.fujitsu.com>	 <1280925913.3011.23.camel@heimdal.trondhjem.org>	 <4C5A213F.9000506@cn.fujitsu.com>	 <1281013423.2948.1.camel@heimdal.trondhjem.org>	 <4C5B8B48.4050008@cn.fujitsu.com>	 <1281101448.3586.11.camel@heimdal.trondhjem.org>	 <4C68EDAE.5000201@cn.fujitsu.com> <1282087012.18385.30.camel@heimdal.trondhjem.org> <4C6B50B3.4090403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49929 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab0HWHoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Aug 2010 03:44:55 -0400
In-Reply-To: <4C6B50B3.4090403@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>> I still don't see why this should be necessary. In the case of a server
>>>> reboot or network partition, the state recovery thread ought to be
>>>> taking care of this for us.
>>>>
>>>    A open state can be found at nfsi->open_states and owner->so_states always, but
>>>   it not be found at nfsi->open_files until we call nfs4_intent_set_file.
>>>
>>>    At _nfs4_do_open, we will invoke nfs4_return_incompatible_delegation to return a 
>>>   delegation,  a open stateid which set NFS_DELEGATED_STATE bit may not be found at
>>>   nfsi->open_files, but it still at nfsi->open_states, so we do not clear 
>>>   NFS_DELEGATED_STATE bit for it.
>>>
>>>    Then _nfs4_do_open will find it by nfs4_get_open_state, and we still use it
>>>   as a delegation, some error will occur.
>>>
>> OK. I see agree that is a race, but AFAICS, your fix means that we end
>> up with an nfs_state structure that has cleared NFS_DELEGATED_STATE, but
>> that did not recover its open stateid.
>>
> 
>   Hi trond, i am not sure my opinion is right.
> 
>   If the state not at nfsi->open_states, i think maybe that means it's not a open stateid,
>   it just a old state we want reuse it. After we update it, it become a open stateid.
> 

Hi trond, have you got a idea to solve this race?

-- 
Regards
Bian Naimeng

