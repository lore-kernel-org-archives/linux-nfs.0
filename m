Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16473 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395Ab2GaOI7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:08:59 -0400
Message-ID: <5017E6F8.2060706@netapp.com>
Date: Tue, 31 Jul 2012 10:08:56 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition
 of 'nfs_commit_inode'
References: <20120731024328.GA10480@localhost>    <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com>    <5017D3FC.9010905@netapp.com> <1343739299.519.1.camel@lade.trondhjem.org>   <5017D824.209@netapp.com> <5017DDDB.6060500@netapp.com>  <1343741622.519.2.camel@lade.trondhjem.org> <5017E13F.4030909@netapp.com> <1343743122.519.4.camel@lade.trondhjem.org>
In-Reply-To: <1343743122.519.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/31/2012 09:58 AM, Myklebust, Trond wrote:
> On Tue, 2012-07-31 at 09:44 -0400, Bryan Schumaker wrote:
>> On 07/31/2012 09:33 AM, Myklebust, Trond wrote:
>>> On Tue, 2012-07-31 at 09:30 -0400, Bryan Schumaker wrote:
>>>> On 07/31/2012 09:05 AM, Bryan Schumaker wrote:
>>>>> On 07/31/2012 08:55 AM, Myklebust, Trond wrote:
>>>>>> On Tue, 2012-07-31 at 08:47 -0400, Bryan Schumaker wrote:
>>>>>>> On 07/30/2012 11:14 PM, Myklebust, Trond wrote:
>>>>>>>> Bryan,
>>>>>>>>
>>>>>>>> Why did you switch to using IS_ENABLED in the first place, and why wasn't that put in a separate patch?
>>>>>>>
>>>>>>> IS_ENABLED() will check for CONFIG_NFS_V*_MODULE, last I checked the defined() macro doesn't.  Putting this into a separate patch makes the change non-bisectable since gcc will be checking against CONFIG_NFS_V3 but CONFIG_NFS_V3_MODULE is set.  Should I have changed the CONFIG_ variables instead of using IS_ENABLED()?
>>>>>>
>>>>>> Why is it evaluating differently in the include file vs. the .c file?
>>>>>> Are we missing an include in nfs_fs.h?
>>>>>
>>>>> Good question.  I don't see any reason that it would evaluate differently, but I'm compiling the .config attached to the initial email to try to figure it out.
>>>>>
>>>>
>>>> Looks like the IS_ENABLED() switch got pushed to the next patch for V3 in include/linux/nfs_fs.h.  Want me to resend the patches?  I took another look at how IS_ENABLED() is defined, and it'll work if I do the switch in the patch before I turn everything into separate modules if you want me to resend everything.
>>>
>>> Please just make it incremental to the patch series that is already
>>> merged in today's nfs-for-3.6.
>>
>> Easy enough, the patch that fixes it is the last one in the series that I sent in yesterday.
> 
> I don't understand. That is the patch series that Fengguang was testing
> afaik. His tests were on 

I'm guessing he's checking each patch individually and it notified about the first bad one.  Here is what happened:

In patch 9 (Convert v3 into a module) one of my calls to IS_ENABLED() somehow got pushed into patch 10.  Here is the bit from patch 10 that fixes the problem:

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4b6043c..2889877 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -538,7 +538,7 @@ extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_commit_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_commit_data *data);

- Bryan


> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
> head:   5c13c9e1c15ee2ca9ab2b953224001af53d9be09
> 
> which includes your patch series from yesterday, no?
> 
>>>
>>> Cheers
>>>   Trond
>>>
>>>>> - Bryan
>>>>>
>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>>> -----Original Message-----
>>>>>>>>> From: Fengguang Wu [mailto:fengguang.wu@intel.com]
>>>>>>>>> Sent: Monday, July 30, 2012 10:43 PM
>>>>>>>>> To: Schumaker, Bryan
>>>>>>>>> Cc: kernel-janitors@vger.kernel.org; Myklebust, Trond; linux-
>>>>>>>>> nfs@vger.kernel.org
>>>>>>>>> Subject: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
>>>>>>>>> 'nfs_commit_inode'
>>>>>>>>>
>>>>>>>>> Hi Bryan,
>>>>>>>>>
>>>>>>>>> Kernel build failed on
>>>>>>>>>
>>>>>>>>> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
>>>>>>>>> head:   5c13c9e1c15ee2ca9ab2b953224001af53d9be09
>>>>>>>>> commit: 1c606fb74c758beafd98cbad9a9133eadeec2371 [46/51] NFS: Convert
>>>>>>>>> v3 into a module
>>>>>>>>> config: blackfin-BF533-EZKIT_defconfig (attached as .config)
>>>>>>>>>
>>>>>>>>> All related error/warning messages:
>>>>>>>>>
>>>>>>>>> fs/nfs/write.c:1592:5: error: redefinition of 'nfs_commit_inode'
>>>>>>>>> In file included from fs/nfs/write.c:19:0:
>>>>>>>>> include/linux/nfs_fs.h:547:1: note: previous definition of 'nfs_commit_inode'
>>>>>>>>> was here
>>>>>>>>>
>>>>>>>>> vim +1592 fs/nfs/write.c
>>>>>>>>>   1589		return status;
>>>>>>>>>   1590	}
>>>>>>>>>   1591
>>>>>>>>>> 1592	int nfs_commit_inode(struct inode *inode, int how)
>>>>>>>>>   1593	{
>>>>>>>>>   1594		LIST_HEAD(head);
>>>>>>>>>   1595		struct nfs_commit_info cinfo;
>>>>>>>>>
>>>>>>>>> ---
>>>>>>>>> 0-DAY kernel build testing backend         Open Source Technology Centre
>>>>>>>>> Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation
>>>>>>>
>>>>>>
>>>>>
>>>>
>>>
>>
> 

