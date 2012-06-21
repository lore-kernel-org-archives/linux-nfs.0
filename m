Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:39032 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760283Ab2FUVES convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2012 17:04:18 -0400
Subject: Re: [PATCH 0/4] Take 2: TEST_STATEID fix-ups
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120613181831.5910.74030.stgit@degas.1015granger.net>
Date: Thu, 21 Jun 2012 17:04:10 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BA1D5E88-5833-484D-9B72-119EDF3E2E2A@oracle.com>
References: <20120613181831.5910.74030.stgit@degas.1015granger.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Do you think these are ready for nfs-for-3.6 ?


On Jun 13, 2012, at 2:20 PM, Chuck Lever wrote:

> For review.
> 
> I discovered a few problems with the new TEST_STATEID implementation
> while testing nograce recovery.  Review comments have been addressed,
> and these have been rebased on 3.5-rc2.
> 
> ---
> 
> Chuck Lever (4):
>      NFS: Refactor nfs41_check_expired_stateid()
>      NFS: State reclaim clears OPEN and LOCK state
>      NFS: Properly sort TEST_STATEID results
>      NFS: Clean up TEST_STATEID and FREE_STATEID proc error reporting
> 
> 
> fs/nfs/nfs4proc.c |  146 ++++++++++++++++++++++++++++++++++++++++++-----------
> 1 files changed, 117 insertions(+), 29 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




