Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51330 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbbJUP7K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2015 11:59:10 -0400
Date: Wed, 21 Oct 2015 11:59:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] create_session: ensure that we send an auth flavor
 in CREATE_SESSION call
Message-ID: <20151021155908.GD27929@fieldses.org>
References: <1445356861-13860-1-git-send-email-jeff.layton@primarydata.com>
 <1445356861-13860-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445356861-13860-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, both pynfs patches applied.--b.

On Tue, Oct 20, 2015 at 12:01:01PM -0400, Jeff Layton wrote:
> ...it is required.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  nfs4.1/server41tests/st_create_session.py | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> index 4c56bb45cc8e..d3b7635545ba 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -13,7 +13,7 @@ def create_session(c, clientid, sequenceid, cred=None, flags=0):
>      chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
>      res = c.compound([op.create_session(clientid, sequenceid, flags,
>                                          chan_attrs, chan_attrs,
> -                                        123, [])], cred)
> +                                        123, [callback_sec_parms4(0)])], cred)
>      return res
>  
>  ###############################################
> @@ -305,7 +305,7 @@ def testRdmaArray2(t, env):
>      chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[13, 57])
>      ops = [op.create_session(c.clientid, c.seqid, 0,
>                               chan_attrs, chan_attrs,
> -                             c.c.prog, [])]
> +                             c.c.prog, [callback_sec_parms4(0)])]
>      c = c.c
>      xid = c.compound_async(ops, checks=False)
>      try:
> -- 
> 2.4.3
