Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919Ab3BQUt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2013 15:49:59 -0500
Date: Sun, 17 Feb 2013 15:49:38 -0500
To: Michael Monnerie <lists.michael.monnerie@is.it-management.at>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to make clients NOT block
Message-ID: <20130217204938.GF11441@fieldses.org>
References: <680509590.JPpPf8D3KZ@saturn>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <680509590.JPpPf8D3KZ@saturn>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 16, 2013 at 12:30:07PM +0100, Michael Monnerie wrote:
> Dear list,
> 
> we've had several servers block today because they all have a NFS mount point 
> from a linux kernel 3.7.6 server. This is the fstab entry:
> 
> 1.1.1.1:/nfsshare/all /shared nfs4 defaults,tcp,intr,relatime,async,acl 0 9
> 
> The NFS server crashed and was offline, that made all clients block.

That's expected.

> Even 
> after the NFS server was up again, most clients were stuck to the point they 
> had to be rebooted.

But that sounds like a bug, on either client or server.

> What mount options should we use so clients don't block 
> completely when the NFS server is gone?

As Boaz says, you can mount with "soft"--but there are good reasons it
isn't the default.  (Worst case it can cause data corruption if your
applications aren't extremely careful.)

--b.

> It's no problem to unmount the NFS 
> share, or get errors, but the clients must not stop their work.
> 
> -- 
> mit freundlichen Grüssen,
> Michael Monnerie, Ing. BSc | Tel: +43 660 415 6531
> 
> XING: https://www.xing.com/profile/Michael_Monnerie
> Facebook: https://www.facebook.com/michael.monnerie
> Twitter: @MichaelMonnerie https://twitter.com/MichaelMonnerie
> LinkedIn: http://lnkd.in/uGx6ug
> Google+: https://plus.google.com/u/0/100598203632716687928/
> 
> Protéger.at Internet Services Austria [gesprochen: Prot-e-schee]
> http://protéger.at | http://proteger.at
> Facebook: https://www.facebook.com/protegerat
> Mitglied im it-management Netzwerk http://it-management.at


