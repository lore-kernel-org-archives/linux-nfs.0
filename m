Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45735 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab0EFVNT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 17:13:19 -0400
Received: by wwb39 with SMTP id 39so349443wwb.19
        for <linux-nfs@vger.kernel.org>; Thu, 06 May 2010 14:13:17 -0700 (PDT)
Message-ID: <4BE330E6.70707@panasas.com>
Date: Fri, 07 May 2010 00:13:10 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
CC: Steve Dickson <steved@redhat.com>
Subject: Re: pnfs git tree status pnfs-all-2.6.34-rc6-2010-05-06 pnfs-all-2.6.33-2010-05-06
References: <4BD9BF01.2000508@panasas.com>
In-Reply-To: <4BD9BF01.2000508@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I released the following today:

pnfs-all-2.6.33-2010-05-06
pnfs-all-2.6.34-rc6-2010-05-06

As usual, cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.33 pnfs-all-2.6.33-2010-05-06
git diff v2.6.34-rc6 pnfs-all-2.6.34-rc6-2010-05-06

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since 2010-04-29):

pnfs-submit:
Andy Adamson (1):
      SQUASHME pnfs: restore state recovery in async handler

Benny Halevy (2):
      SQUASHME: pnfs-submit: have initialize_mountpoint return status
      SQUASHME: pnfs-submit: pass struct nfs_server * to getdeviceinfo

Fred Isaman (4):
      SQUASHME: pnfs_submit: Revert the pnfs_write_end part of "pnfs: commit and pnfs_write_end"
      SQUASHME: pnfs_submit: Revert "pnfs: pnfs_modify_new_request"
      SQUASHME: pnfs_submit: Revert "pnfs: propagate fsdata into nfs_create_request"
      SQUASHME: pnfs_submit: Revert "pnfs: pnfs_do_flush"

Zhang Jingwang (1):
      SQUASHME: pnfs-submit: Free layoutcommit_data when error occurs in setup

pnfs:
Andy Adamson (4):
      pnfs_post_submit: restore CB_NOTIFY_DEVICEID
      pnfs_post_submit: restore GETDEVICELIST
      pnfs_post_submit: restore ds_wsize and ds_rsize
      pnfs_post_submit: restore get_blocksize policy operation

Benny Halevy (3):
      pnfs-post-submit: pass struct nfs_server * to getdevicelist
      pnfs-post-submit: pass mntfh down the init_pnfs path
      FIXME: pnfs-post-submit: per mount layout driver private data

Fred Isaman (4):
      pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
      pnfs_post_submit: Restore "pnfs: propagate fsdata into nfs_create_request"
      pnfs_post_submit: Restore "pnfs: pnfs_modify_new_request"
      pnfs_post_submit: Revert the pnfs_write_end part of "pnfs: commit and pnfs_write_end"

pnfs-block:
Benny Halevy (1):
      SQUASHME: pnfs-block: convert APIs pnfs-post-submit

Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

pnfs-obj-all:
Benny Halevy (1):
      SQUASHME: pnfs-obj: convert APIs pnfs-post-submit


> 
> pnfs-all-2.6.33:
> Benny Halevy (1):
>       pnfs-block: revert workaround for NFS4_GETDEVINFO_MAXSIZE
> 
> J. Bruce Fields (1):
>       pnfs-block: fix compile breakage
> 
> Mike Sager (1):
>       pnfsblock: use the session max response size for getdeviceinfo's maxcount
> 
> Zhang Jingwang (1):
>       SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
> 
> Zhengju Sha (1):
>       pnfsd: using sbid instead of fsid while returning device list to client
> 
> nfs-upstream:
> Trond Myklebust (1):
>       NFS: Fix an unstable write data integrity race
> 
> pnfs-submit:
> Tao Guo (1):
>       pnfs: Reduce layout lookup times with sorted lseg list.
> 
> pnfs-block:
> J. Bruce Fields (1):
>       SQUASHME: pnfs-block: fix compile breakage
> 
> Mike Sager (1):
>       pnfsblock: use the session max response size for getdeviceinfo's maxcount
> 
> Zhang Jingwang (1):
>       SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
> 
> pnfsd-files:
> Benny Halevy (1):
>       pnfsd: define layout_lock
> 
> Zhengju Sha (1):
>       SQUASHME: pnfsd: using sbid instead of fsid while returning device list to client
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

