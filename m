Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53838 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752585AbcLVUfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Dec 2016 15:35:02 -0500
Date: Thu, 22 Dec 2016 15:35:01 -0500
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 4/4] mountd: delay reading etab until first request
 arrives.
Message-ID: <20161222203501.GA31461@fieldses.org>
References: <148227940052.31345.1974080582264239934.stgit@noble>
 <148227955423.31345.17642862410755193193.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <148227955423.31345.17642862410755193193.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 21, 2016 at 11:19:14AM +1100, NeilBrown wrote:
> Reading etab may require hostname lookup, so it is not reliable
> until the network is active.
> But we want mountd to start before that so that it is ready
> when the very first NFS request arrives.
> So delay reading etab until that request arrives, by which time
> the network must be online so hopefully hostname look will be reliable.
> 
> An alternate would be to delay starting mountd and nfsd until the
> network is on-line, but that will often be an unnecessary delay.

One argument for that delay would be to get the grace period right: it's
not really correct to start timing the grace period before you start
accepting requests.

In practice, with grace periods by default a minute and (I'm guessing)
the delay here not even a few seconds, maybe it's a minor point.

And in theory I guess knfsd could account for that by waiting to start
the grace period timer until it receives its first rpc.

Anyway, that's not an objection to applying this patch.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mountd/mountd.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 5d9466f5c651..61699e62a6f0 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -852,8 +852,6 @@ main(int argc, char **argv)
>  	sa.sa_handler = sig_hup;
>  	sigaction(SIGHUP, &sa, NULL);
>  
> -	auth_init();
> -
>  	if (!foreground) {
>  		/* We first fork off a child. */
>  		if ((c = fork()) > 0)
> 
