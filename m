Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36826 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaAEUaq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 15:30:46 -0500
Date: Sun, 5 Jan 2014 15:30:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: Re: [PATCH 0/3] sunrpc: change handling of use-gss-proxy file
Message-ID: <20140105203045.GC22918@fieldses.org>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 04, 2014 at 07:18:02AM -0500, Jeff Layton wrote:
> This patchset fixes a couple of problems with the use-gss-proxy procfile
> and does some general cleanup around that code. Bruce, can you consider
> this for 3.14? Getting it into linux-next soon would be good too...

Yep, applied locally, should get pushed out tomorrow-ish.

I suppose the first should also go to stable if the "tar up /proc" case
merits it.

The races look like they require pretty unusual userspace behavior, so
I'm not inclined to backport those.

--b.

> 
> Thanks,
> 
> Jeff Layton (3):
>   sunrpc: don't wait for write before allowing reads from use-gss-proxy
>     file
>   sunrpc: fix potential race between setting use_gss_proxy and the
>     upcall rpc_clnt
>   sunrpc: get rid of use_gssp_lock
> 
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |  2 -
>  net/sunrpc/auth_gss/svcauth_gss.c    | 75 ++++++++++--------------------------
>  net/sunrpc/netns.h                   |  1 -
>  3 files changed, 20 insertions(+), 58 deletions(-)
> 
> -- 
> 1.8.4.2
> 
