From: Simon Kirby <sim@hostway.ca>
Subject: Re: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Sat, 20 Jun 2009 22:09:41 -0700
Message-ID: <20090621050941.GA17059@hostway.ca>
References: <20090619225437.GA8472@hostway.ca> <1245527855.5182.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:46275 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751354AbZFUFJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Jun 2009 01:09:42 -0400
In-Reply-To: <1245527855.5182.33.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 20, 2009 at 03:57:35PM -0400, Trond Myklebust wrote:

> Looks more like some kind of memory scribble to me. The value of
> xprt->ops never changes after initialisation of the transport.
> 
> Have you tried turning on the various memory debugging tools?

Hi Trond,

No, but I will try this now.

Actually, we just saw another similar crash on another machine which is
an NFS client from this server (no nfsd running).  Same backtrace, but
this time RAX was "32322e32352e3031", which is obviously ASCII
("22.25.01"), so memory scribbling seems to definitely be happening...

Simon-
