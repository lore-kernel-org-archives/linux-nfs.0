Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:32871 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681Ab1LMRjL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 12:39:11 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RaWJp-00006A-S9
	for linux-nfs@vger.kernel.org; Tue, 13 Dec 2011 18:39:10 +0100
Received: from user-387o921.cable.mindspring.com ([208.124.36.65])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Dec 2011 18:39:09 +0100
Received: from chris.j.arges by user-387o921.cable.mindspring.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Dec 2011 18:39:09 +0100
To: linux-nfs@vger.kernel.org
From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Date: Tue, 13 Dec 2011 17:38:54 +0000 (UTC)
Message-ID: <loom.20111213T183631-8@post.gmane.org>
References: <20110825161957.GC1114@fieldses.org> <loom.20111207T233110-295@post.gmane.org> <20111208212151.GF32505@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

<snip>
> > 
> > 
> > Bruce,
> > 
> > I've tested this patch against linux-3.0 and it doesn't allow me to execute 
> > binaries with permissions of 111.
> 
> Hm, I see the same permissions error.  However, looking at the
> client-server traffic with wireshark, I see no permissions failures from
> the server: the read-open of cat succeeds.  (Could you check if the same
> is true in your case?)
> 
> So my first inclination is to blame the client.... Does this work with
> an older client?
> 
> --b.

Bruce,

Using the above test setup, and trying various clients I see a mismatch:

Using a newer nfs clients (nfs-common 1:1.2.2-4/1:1.2.4-1), I can read a file 
with 111 permissions, but cannot execute it.
With an older nfs client (nfs-common 1:1.2.0-4 / ubuntu lucid), I can read and 
execute a file with 111 permissions.

--chris j arges

<snip>




