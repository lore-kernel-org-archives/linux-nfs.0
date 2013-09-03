Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26241 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761170Ab3ICTM0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 15:12:26 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Initial SP4_MACH_CRED implementation
Date: Tue, 3 Sep 2013 19:12:25 +0000
Message-ID: <9420930C-E6FD-4F0B-BB4E-A634499DB0B3@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

I think that these patches are missing put_rpccred() calls when we change rpc_message.

I'll add and repost…

-dros

On Aug 13, 2013, at 4:37 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> This is version 2 of this patchset including some cleanup, refactoring and
> fixes a few build issues with different configs.
> 
> I also added a few patches:
> - WRITE and/or COMMIT support - tested on a hacked nfsd
> - map NFS4ERR_WRONG_CRED (an common SP4 error) to EPERM
> 
> I meant to include a patch that only uses the machine cred (for 'allow' ops)
> when the user cred has expired, but after talking with Andy, I decided to wait
> for his cred expiration patchset to be merged as we'd be touching the same
> places and possibly duplicating effort.
> 
> Weston Andros Adamson (7):
>  nfs4.1: Minimal SP4_MACH_CRED implementation
>  nfs4.1: Add state protection handler
>  nfs4.1: Add SP4_MACH_CRED cleanup support
>  nfs4.1: Add SP4_MACH_CRED secinfo support
>  nfs4.1: Add SP4_MACH_CRED stateid support
>  nfs4.1: Add SP4_MACH_CRED write and commit support
>  nfs4: Map NFS4ERR_WRONG_CRED to EPERM
> 
> fs/nfs/nfs4_fs.h          |  67 ++++++++++++++++
> fs/nfs/nfs4proc.c         | 191 ++++++++++++++++++++++++++++++++++++++++++++--
> fs/nfs/nfs4xdr.c          |  72 ++++++++++++++---
> fs/nfs/write.c            |   6 ++
> include/linux/nfs_fs_sb.h |   9 +++
> include/linux/nfs_xdr.h   |  19 +++++
> 6 files changed, 346 insertions(+), 18 deletions(-)
> 
> -- 
> 1.7.12.4 (Apple Git-37)
> 

