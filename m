Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300Ab0K1QFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Nov 2010 11:05:45 -0500
Date: Sun, 28 Nov 2010 11:05:43 -0500
To: Jan Engelhardt <jengelh@medozas.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: server error: fileid changed
Message-ID: <20101128160543.GA18889@fieldses.org>
References: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 28, 2010 at 03:23:23PM +0100, Jan Engelhardt wrote:
> Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
> unreliable, having clients start to emit messages like
> 
> (nfsv3)
> [42306.521225] NFS: server nova error: fileid changed
> [42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0
> 
> On nfsv4, it is even worse, as updates on the server are not immediately 
> reflected on the client like it was the case on nfsv3.
> Unfortunately, that is all the information I currently have.
> (Server is on 2.6.36-rc8, client on 2.6.37-rc1.)

Have you really being changing only the server, or have you been
changing the client at the same time?

See e.g.

	http://marc.info/?l=linux-nfs&m=129088225122788&w=2

--b.
