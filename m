Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757561Ab3EHS1s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 14:27:48 -0400
Message-ID: <518A9920.2030302@RedHat.com>
Date: Wed, 08 May 2013 14:27:44 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/17] NFS: Client implementation of Labeled-NFS
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>    <1367240239-19326-14-git-send-email-SteveD@redhat.com>   <1367435005.4189.36.camel@leira.trondhjem.org>   <518A7FA6.4090703@RedHat.com>  <1368031432.5978.3.camel@leira.trondhjem.org> <518A8DBE.3010107@RedHat.com> <1368036422.5978.25.camel@leira.trondhjem.org>
In-Reply-To: <1368036422.5978.25.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/05/13 14:07, Myklebust, Trond wrote:
> On Wed, 2013-05-08 at 13:39 -0400, Steve Dickson wrote:
>>
>> On 08/05/13 12:43, Myklebust, Trond wrote:
>>> On Wed, 2013-05-08 at 12:39 -0400, Steve Dickson wrote:
>>>>
>>>> On 01/05/13 15:03, Myklebust, Trond wrote:
>>>>>> @@ -2409,10 +2468,26 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
>>>>>>>  			server->caps |= NFS_CAP_CTIME;
>>>>>>>  		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
>>>>>>>  			server->caps |= NFS_CAP_MTIME;
>>>>>>> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
>>>>>>> +		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
>>>>>>> +			server->caps |= NFS_CAP_SECURITY_LABEL;
>>>>>>> +#endif
>>>>>>> +		memcpy(server->attr_bitmask_nl, res.attr_bitmask, 
>>>>>>> +				sizeof(server->attr_bitmask));
>>>>>>> +
>>>>>>> +		if (server->caps & NFS_CAP_SECURITY_LABEL)
>>>>>>> +			server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
>>>>>>>  
>>>>>>>  		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
>>>>>>>  		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
>>>>>>> -		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
>>>>>>> +		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA |
>>>>>>> +							FATTR4_WORD1_TIME_MODIFY;
>>>>>>> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
>>>>>>> +		server->cache_consistency_bitmask[2] &= FATTR4_WORD2_SECURITY_LABEL;
>>>>> Why? How is the security label relevant to cache consistency?
>>>> Its used to the set label bit in the GETATTR that goes out with ACCESS compound.
>>>
>>> The GETATTR that goes out with ACCESS is only there in order to get the
>>> change attribute so that we know when to invalidate the access cache. It
>>> is _only_ for cache consistency.
>>>
>>> Why do we need to fetch the label too?
>>>
>> I think I answer this in the other thread but in short 
>> access updates the inode and so it appears the goal 
>> is to synchronize inode updates and label updates.
> 
> Those are not inode updates.
Ah... OK... but they all end up calling nfs_refresh_inode() with 
the valid label pointer... So there is an effort to keep the 
inode attribute cache updates synchronized with label updates... 

So I guess the question is that needed... Is the setting of 
the label in nfs_fhget() and/or _nfs4_do_open() good enough.

steved.



