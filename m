Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42967 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758047Ab2EPNzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 09:55:36 -0400
Date: Wed, 16 May 2012 09:55:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] nfsd: clean up share access with accessor functions
Message-ID: <20120516135535.GC17471@fieldses.org>
References: <1336743914-944-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2012 at 09:45:10AM -0400, Jeff Layton wrote:
> While looking over the share/deny mode stuff in knfsd, I ended up doing
> some cleanup to make the code a bit easier to understand. In the future
> this may help us by encapsulating the share/deny code to some degree.
> 
> This set should introduce no behavioral changes, it's just cleanup for
> now, but is probably reasonable for 3.5.

Thanks, those look fine, applying.--b.

> 
> Jeff Layton (4):
>   nfsd: consolidate set_access and set_deny
>   nfsd: make test_share a bool return
>   nfsd: wrap accesses to st_access_bmap
>   nfsd: wrap all accesses to st_deny_bmap
> 
>  fs/nfsd/nfs4state.c |  149 ++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 93 insertions(+), 56 deletions(-)
> 
> -- 
> 1.7.7.6
> 
