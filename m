Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64640 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754630AbaAATxx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jan 2014 14:53:53 -0500
Subject: Re: [RFC PATCH 0/5] sunrpc: change handling of use-gss-proxy file
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
In-Reply-To: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Jan 2014 14:53:45 -0500
Message-ID: <1388606025.26102.10.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-01-01 at 07:28 -0500, Jeff Layton wrote:
> Consider this patch a RFC at this point. This changes how the
> use-gss-proxy file works, and alters the kernel upcall to delay a little
> bit before giving up on it if gssproxy isn't up yet.
> 
> It's not heavily tested yet, but it seems to do the right thing...
> 
> I think the first patch isn't too controversial. The big question is
> whether the initial upcall delay is desirable.
> 
> Thoughts?
> 
> Jeff Layton (5):
>   sunrpc: don't wait for write before allowing reads from use-gss-proxy
>     file
>   sunrpc: don't hang indefinitely in wait_for_gss_proxy
>   sunrpc: wait for gssproxy to start on initial upcall attempt before
>     falling back to legacy upcall
>   sunrpc: fix potential race between setting use_gss_proxy and the
>     upcall rpc_clnt
>   sunrpc: allow gssproxy to be explicitly disabled from userland
> 
>  net/sunrpc/auth_gss/svcauth_gss.c | 72 +++++++++++++++++++++------------------
>  1 file changed, 39 insertions(+), 33 deletions(-)
> 

I like the whole patchset but ahven't tested any of it. so consider a
tentative ack by me.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

