Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47965 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757886Ab2JXVcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 17:32:14 -0400
Date: Wed, 24 Oct 2012 17:32:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/4] nfsd: add a usermodehelper upcall for client id
 tracking
Message-ID: <20121024213213.GI6697@fieldses.org>
References: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 10:30:14AM -0400, Jeff Layton wrote:
> This is a respin of the set with the same title that I sent on October
> 3rd. The main difference is the addition of a printk warning for people
> that are using the nfsdcld upcall, and some minor bugfixes and renaming
> of functions for consistency.
> 
> I'd like to see this go into 3.8 if possible.

Thanks, two questions (see individual replies) aside, this seems fine.

--b.

> 
> Jeff Layton (4):
>   nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
>   nfsd: change heuristic for selecting the client_tracking_ops
>   nfsd: pass info about the legacy recoverydir in environment variables
>   nfsd: warn about impending removal of nfsdcld upcall
> 
>  fs/nfsd/nfs4recover.c | 247 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 237 insertions(+), 10 deletions(-)
> 
> -- 
> 1.7.11.7
> 
