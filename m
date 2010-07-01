From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/10] pnfs-submit add layoutget,layoutreturn error handling
 version 2
Date: Thu, 01 Jul 2010 21:27:41 +0300
Message-ID: <4C2CDE1D.2070102@panasas.com>
References: <1277320878-3726-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5870 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932247Ab0GAS1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:27:44 -0400
In-Reply-To: <1277320878-3726-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-06-23 22:21, andros@netapp.com wrote:On Jun. 23, 2010, 22:21 +0300, andros@netapp.com wrote:
> Responded to comments, added a 2 cleanup patchses
> 
> Plus some code cleanup
> 0001-SQUASHME-pnfs-submit-remove-unused-filelayout_mount_.patch
> 
> and some bug fixes
> 0002-SQUASHME-pnfs-submit-pnfs_try_to_read-write-commit-u.patch
> 
> NOTE: this patch: 0003-SQUASHME-pnfs-submit-tell-commit-to-use-the-MDS.patch
> was replaced by:
> 0003-SQUASHME-pnfs-submit-clear-page-lseg-on-partial-i-o.patch
> 

All but patch 3/10 (as per your request) are merged at
pnfs-all-2.6.35-rc3-2010-07-01

Thanks!

Benny

> 
> Remove unused (by file layout) encode_layoutreturn io operation
> 0004-SQUASHME-pnfs-submit-remove-encode_layoutreturn.patch
> 0005-SQUASHME-pnfs-submit-add-error-handling-to-layout-re.patch
> 
> 0006-SQUASHME-pnfs-submit-handle-assassinated-layoutcommi.patch
> 
> Note: pnfs4_proc_layoutget is only called by send_layout() which prints
> the status.
> 0007-SQUASHME-pnfs-submit-add-error-handlers-to-layout-ge.patch
> 
> Add back encode_layoutreturn io operation
> 0008-pnfs-post-submit-restore-encode_layoutreturn.patch
> 
> 
> New patches:
> 0009-SQUASHME-pnfs-submit-don-t-re-initialize-i_lock.patch
> 
> This gets rid of a frame stack warning;
> 0010-SQUASHME-pnfs-submit-remove-struct-nfs_server-from-s.patch
> 
> Testing:
> ---------
> 
> CONFIG_NFS_V4_1 set: NFSv4.0 NFSv4.1 pNFS
> Passes Connectathon tests
> 
> Tested layoutget and layoutreturn recovery from NFS4ERR_DEAD_SESSION with the
> pyNFS server and the testclient framework.
> 
> Still todo:
> 
> Recover from NFS4ERR_BAD_STATEID. Currently layoutreturn, layoutget, and
> layoutcommit do not pass nfs_stste to the error handlers.
> 
> Handle NFS4ERR_BAD_LAYOUT.
> 
> CONFIG_NFS_V4_1 not set: NFSv4.o mount passes cthon tests.
> 
> -->Andy


-- 
Benny Halevy
Software Architect
Panasas, Inc.
bhalevy@panasas.com
Tel/Fax: +972-3-647-8340
Mobile: +972-54-802-8340

Panasas: The Leader in Parallel Storage
www.panasas.com
