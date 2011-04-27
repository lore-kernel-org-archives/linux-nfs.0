Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40733 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759787Ab1D0SBu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 14:01:50 -0400
Subject: Re: [PATCH] nfs: don't lose MS_SYNCHRONOUS on remount of noac mount
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303919349-30207-1-git-send-email-jlayton@redhat.com>
References: <1303919349-30207-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 14:01:47 -0400
Message-ID: <1303927307.13195.20.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-27 at 11:49 -0400, Jeff Layton wrote:
> On a remount, the VFS layer will clear the MS_SYNCHRONOUS bit on the
> assumption that the flags on the mount syscall will have it set if the
> remounted fs is supposed to keep it.
> 
> In the case of "noac" though, MS_SYNCHRONOUS is implied. A remount of
> such a mount will lose the MS_SYNCHRONOUS flag since "sync" isn't part
> of the mount options.
> 
> Reported-by: Max Matveev <makc@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Should this be 'Cc: stable@kernel.org'?
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

