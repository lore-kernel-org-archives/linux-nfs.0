Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:45875 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbbHYNNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 09:13:42 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 1692F280896
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 15:13:41 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 02D0F136F
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 15:13:40 +0200 (MEST)
Date: Tue, 25 Aug 2015 15:13:40 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Gil Amsalem <gil.amsalem@primarydata.com>
Message-ID: <1598648139.3927267.1440508420596.JavaMail.zimbra@desy.de>
In-Reply-To: <1440508327-6221-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1440508327-6221-1-git-send-email-tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH] When trying to establish privileged source port number
 of tcp connection, use 1 instead of 0 as start port, as 0 means that the
 kernel will choose the port number
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I got this patch through github, where I have a clone of the pynfs repository.

Tigran.

----- Original Message -----
> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> To: bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org, "Gil Amsalem" <gil.amsalem@primarydata.com>, "Tigran Mkrtchyan"
> <tigran.mkrtchyan@desy.de>
> Sent: Tuesday, August 25, 2015 3:12:07 PM
> Subject: [PATCH] When trying to establish privileged source port number of tcp connection, use 1 instead of 0 as start
> port, as 0 means that the kernel will choose the port number

> From: Gil Amsalem <gil.amsalem@primarydata.com>
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
> rpc/rpc.py | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/rpc/rpc.py b/rpc/rpc.py
> index 83a0222..1a3ca38 100644
> --- a/rpc/rpc.py
> +++ b/rpc/rpc.py
> @@ -824,7 +824,7 @@ class ConnectionHandler(object):
>         defer.wait()
>         return pipe
> 
> -    def bindsocket(self, s, port=0):
> +    def bindsocket(self, s, port=1):
>         """Scan up through ports, looking for one we can bind to"""
>         # This is necessary when we need to use a 'secure' port
>         using = port
> --
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
