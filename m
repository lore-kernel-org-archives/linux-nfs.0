Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:37283 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965108Ab2JXBbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 21:31:15 -0400
Message-ID: <50874522.7060602@asianux.com>
Date: Wed, 24 Oct 2012 09:32:18 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Ric Wheeler <rwheeler@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Jun YOSHIDA <jun@asianux.com>
Subject: [RH Bug 858978] All root cause found (2 root causes, 1 from up stream,
 1 from Red Hat)
References: <50850B1D.7060204@asianux.com> <5085EE82.40401@asianux.com> <5086FD5F.8080900@redhat.com>
In-Reply-To: <5086FD5F.8080900@redhat.com>
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello linux-nfs@vger.kernel.org:


1) Firstly, sorry for bothering you:

   A) I met an issue from Red Hat, it was about nfs-client of
kernel-2.6.18-308.16.1.el5.

   B) The relative member of Red Hat suggested me to send mail to
linux-nfs@vger.kernel.org, so I do it.

   C) Please see the bottom of this mail to get details of suggestions.


2) Please help to confirm:

   A) Asianux found, analysed, and provided solving ways for this issue.

   B) Please help to check what Asianux have done (whether correct).

   C) Details are in bottom of mail (or see Red Hat Bugzilla Bug858978)


3) Asianux Goal:

   A) Asianux want to give their contributes to the Open Source, just as
Asianux have already get benefits from the Open Source.

   B) Asianux will do what they can do for it, currently, Asianux are
focus on Linux kernel (including NFS, but not only NFS; including Red
Hat release, but not only Red Hat release)

   C) Welcome another members or organizations to giving suggestions and
completions.



   thanks.

--
Chen Gang

Asianux Corporation




于 2012年10月24日 04:26, Ric Wheeler 写道:
> 
> Hi Chen,
> 
> Please send all of your email *only* to the upstream NFS lists (
> linux-nfs@vger.kernel.org ). Unless you pay us or become an official partner of
> Red Hat, I cannot ask my developer team to work with you on a clone of our product.
> 
> Best regards,
> 
> Ric Wheeler
> 
> 
> We are more than happy to work with you upstream
> On 10/22/2012 09:10 PM, Chen Gang wrote:
>> Please confirm what I said below whether correct or not, thanks.
>>
>> At least, it is truly an issue of Red Hat own.
>> So it is suitable to get the confirmation from Red Hat
>>
>>   1) if you can not confirm whether it is correct or not;
>>   2) I will send these confirmation to kernel-mgr@redhat.com;
>>   3) I believe they can confirm the issue of Red Hat own.
>>
>> thanks.
>>
>>
>>
>> 于 2012年10月22日 17:00, Chen Gang 写道:
>>> Hello Ric Wheeler, Jeff Layton:
>>>
>>>
>>> For this Bug, has 2 root causes totally.
>>>
>>> one from upstream, I am just communicating with relative members in
>>> upstream kernel mailing list.
>>>
>>>
>>> the other is from Red Hat their own (upstream not have), please check it
>>> by Jeff Layton, thanks.
>>>
>>> the root cause which Red Hat their own is:
>>> -----------------------------------------------------------------------
>>> the nfs_update_inode in fs/nfs/inode.c has no enough information to
>>> judge whether should change nfsi->attr_gencount (NFS_INO_INVALID_ATTR
>>> should be set for invalid).
>>>
>>> so when truncate operation occurs, it will set the file size outside of
>>> nfs_update_inode, and then when it call nfs_update_inode, the
>>> NFS_INO_INVALID_ATTR not set, nfsi->attr_gencount is still old.
>>>
>>> and then async read_done comes, it's fattr->gencount is later than the
>>> nfsi->attr_gencount, so nfs_update_inode will be called (which should
>>> not be called in this situation).
>>>
>>> For upstream kernel, no this issue (it has enough information in
>>> fs/nfs/inode.c to judge whether should change nfsi->attr_gencount).
>>> -----------------------------------------------------------------------
>>>
>>>
>>> please see the Bugzilla to check the more details (including dump log
>>> for the analysing data support. also how to fix it, and let it pass the
>>> fsx-linux test finally).
>>>
>>>
>>> welcome any additional suggestions or completions.
>>>
>>> thanks.
>>>
>>
> 
> 
> 


-- 
Chen Gang

Asianux Corporation
