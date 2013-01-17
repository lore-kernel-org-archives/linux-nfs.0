Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:51029 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557Ab3AQXlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 18:41:09 -0500
Message-ID: <50F88C14.7030903@teksavvy.com>
Date: Thu, 17 Jan 2013 18:41:08 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com>
In-Reply-To: <50F7FB7E.2020503@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-17 08:24 AM, Stanislav Kinsbursky wrote:
..
> This looks like the old issue I was trying to fix with "SUNRPC: protect service sockets lists during
> per-net shutdown".
> So, here is the problem as I see it: there is a transport, which is processed by service thread and
> it's processing is racing with per-net service shutdown:
> 
> CPU#0:                            CPU#1:
> 
> svc_recv                        svc_close_net
> svc_get_next_xprt (list_del_init(xpt_ready))
>                             svc_close_list (set XPT_BUSY and XPT_CLOSE)
>                             svc_clear_pools(xprt was gained on CPU#0 already)
>                             svc_delete_xprt (set XPT_DEAD)
> svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
> BUG()
> 
> So, from my POW, we need some way to:
> 1) Skip such in-progress transports on svc_close_net() call (there is not way to detect them, or at 
> least I don't see one)
> 2) Delete the transport after somewhere after svc_xprt_received()
> 
> But there is a problem with svc_xprt_received(): there is a call for svc_xprt_put() in it
> (svc_recv->svc_handle_xprt->svc_xprt_received->svc_xprt_put) . And if we are the only user - then
> the transport will be destroyed. But transport is dereferenced later in svc_recv() after the
> svc_handle_xprt call.

Sounds like a reference count type of problem/solution (kref) (?)

