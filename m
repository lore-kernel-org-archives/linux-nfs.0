From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
Date: Wed, 29 Sep 2010 16:09:07 +0200
Message-ID: <4CA34883.40005@desy.de>
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:44230 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab0I2OJe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 10:09:34 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 4A7671184
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 16:09:33 +0200 (MEST)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 4320A1146
	for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 16:09:33 +0200 (MEST)
In-Reply-To: <4CA34830.1040703@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  On 09/29/2010 04:07 PM, Tigran Mkrtchyan wrote:
>
> I am support to publish first kernel crash.....
sorry to publish....

>
> this is
> pnfs-all-2.6.36-rc6-2010-09-29 git 
> c2b3b75c6b1db1dfc3f236200de1763e14c514d8
>
> Regards,
>    Tigran.
>
>
> On 09/29/2010 01:06 PM, Benny Halevy wrote:
>> This version includes Fred's pnfs-submit RFC patches (v5).
>> and is rebased onto v2.6.36-rc6
>>
>> Cumulative patches can be generated from
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git
>> using
>> git diff v2.6.36-rc6 pnfs-all-2.6.36-rc6-2010-09-29
>>
>> Or, they can be downloaded from the wiki at:
>> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree
>>
>> Latest patches (since pnfs-all-2.6.36-rc3-2010-08-30):
>>
>> upstream:
>>    Boaz Harrosh     cc59b6a um: Proper Fix for f25c80a4: remove 
>> duplicate structure field initialization
>>
>> pnfs-submit:
>>    The pNFS Team    1851dbc RFC: pnfsd, pnfs: protocol level pnfs 
>> constants
>>    The pNFS Team    a1b60af RFC: nfs: change stateid to be a union
>>    The pNFS Team    ff38ee4 RFC: nfs: ask for layouttypes during 
>> fsinfo call
>>    The pNFS Team    01f09aa RFC: nfs: set layout driver
>>    The pNFS Team    f7893b6 RFC: pnfs: full mount/umount infrastructure
>>    The pNFS Team    1cef5e0 RFC: pnfs: filelayout: introduce minimal 
>> file layout driver
>>    The pNFS Team    b7e2a3d RFC: nfs: create and destroy inode's 
>> layout cache
>>    The pNFS Team    34d2802 RFC: nfs: client needs to maintain list 
>> of inodes with active layouts
>>    The pNFS Team    292b90e RFC: pnfs: add LAYOUTGET and 
>> GETDEVICEINFO infrastructure
>>    The pNFS Team    bf610f6 RFC: pnfs: filelayout: add driver's 
>> LAYOUTGET and GETDEVICEINFO infrastructure
>>    Fred Isaman      068e761 pnfs-submit: revert range simplifications 
>> made by submission patches
>>    Benny Halevy     7c58c3d SQUASHME: pnfs-submit: add missing 
>> include file in nfs4filelayoutdev.c
>>    Benny Halevy     9a5956f SQUASHME: move nfs4_deviceid definitions 
>> to include/linux/nfs4.h
>>    Benny Halevy     bb2afce SQUASHME: pnfs-submit: handle non-pnfs 
>> case in set_pnfs_layoutdriver
>>    Benny Halevy     998fe4a pnfs-submit: file needs layout commit, 
>> server attributes may be stale
>>    Benny Halevy     f18cdf8 NFS: clear fsinfo before sendign rpc
>>
>> pnfs:
>>    Benny Halevy     52a6277 pnfs: alloc and free layout_hdr 
>> layoutdriver methods
>>    Benny Halevy     6dd521e pnfs: allow nfs4_proc_layoutget to sleep 
>> on invalid lsegs
>>    Benny Halevy     ba1dd5b SQUASHME: pnfs: refactor put_lseg{_locked}
>>    Benny Halevy     bb03ecf SQUASHME: pnfs: get rid of lo_waitq
>>
>> pnfs-block:
>>    Benny Halevy     73b1db9 SQUASHME: pnfsblock: remove obsolete 
>> include file from blocklayout.h
>>    Benny Halevy     d9ebc26 SQUASHME: pnfsblock: use nfs4_deviceid
>>    Benny Halevy     90e2af1 SQUASHME: pnfsblock: no callback ops
>>    Benny Halevy     0953b90 SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
>>    Benny Halevy     7ab3774 SQUASHME: pnfsblock: no dev_notify_types
>>    Benny Halevy     f08f966 SQUASHME: pnfsblock: use new struct 
>> pnfs_layout_hdr
>>
>> pnfs-obj-all:
>>    Benny Halevy     41a70b7 SQUASHME: pnfs-obj: fix REQ flags usage
>>    Benny Halevy     6057701 SQUASHME: pnfs-obj: convert to new 
>> pnfs-submit changes
>>
>> pnfs-exofs-all:
>>    Benny Halevy     10d8e6e SQUASHME: pnfsd-exofs: convert to new 
>> pnfs-submit changes
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

