Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756977Ab1FUR45 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 13:56:57 -0400
Date: Tue, 21 Jun 2011 13:56:55 -0400
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: missing verifier in rpcsec_gss calls
Message-ID: <20110621175655.GA26923@fieldses.org>
References: <4E005383.6030206@desy.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E005383.6030206@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 21, 2011 at 10:17:07AM +0200, Tigran Mkrtchyan wrote:
> this is what I am observing with v4.0 and v4.1.
> sometimes, mostly on RPCSEC_GSS_DESTROY,
> in the PC calls missing verifier. This is against my
> server and linux server.
> 
> Packets attached. Please have a look at the packet 15.
> 100% reproducible.
> 
> 
> I tried vanilla 2.6.39 and 3.0.0-rc3 from
> git://linux-nfs.org/~trondmy/nfs-2.6.git
>    9cff1ffd4d477f541d5644f0ec25ee40025fa806 origin/linux-next

Looking at the code quickly:

The only place I see gss headers encoded is in gss_marshal(), which
unconditionally encodes the verifier.

So the length must be getting messed up after that?

I don't see it....

--b.
