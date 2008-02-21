From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Wrap buffers used for rpc debug printks into
	RPC_IFDEBUG
Date: Thu, 21 Feb 2008 16:45:22 -0500
Message-ID: <1203630322.8258.35.camel@heimdal.trondhjem.org>
References: <47BD2EF9.4010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:51941 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761142AbYBUVp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 16:45:27 -0500
In-Reply-To: <47BD2EF9.4010309@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-02-21 at 10:57 +0300, Pavel Emelyanov wrote:
> Sorry for the noise, but here's the v3 of this compilation fix :)
> 
> There are some places, which declare the char buf[...] on the stack
> to push it later into dprintk(). Since the dprintk sometimes (if the 
> CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
> cause gcc to produce appropriate warnings.
> 
> Wrap these buffers with RPC_IFDEBUG macro, as Trond proposed, to 
> compile them out when not needed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks Pavel!

Bruce, do you want to shepherd this in, or should I? I'm planning on
pushing a couple of bugfixes to Linus this evening anyway...

Cheers
  Trond

