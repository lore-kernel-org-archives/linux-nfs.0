From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] the infamous" device is busy" bug
Date: Mon, 16 Jun 2008 14:42:40 -0400
Message-ID: <20080616184240.GD27083@fieldses.org>
References: <mailman.32188.1213350650.3945.nfs@lists.sourceforge.net>
	<p06240404c478afa53f34@[129.98.90.227]>
	<53236.192.168.1.70.1213405151.squirrel@neil.brown.name>
	<p06240405c4790372e350@[129.98.90.227]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Maurice Volaski <mvolaski-Q33DkHiyi7z2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49112 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbYFPSmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 14:42:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K8JfH-0003M7-V6
	for linux-nfs@vger.kernel.org; Tue, 17 Jun 2008 04:42:52 +1000
In-Reply-To: <p06240405c4790372e350@[129.98.90.227]>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 14, 2008 at 01:20:26AM -0400, Maurice Volaski wrote:
> >should release it, though if there are active clients, one could grab it
> >again very quickly.
> >Alternately
> >    rpc.nfsd 0
> >    exportfs -f
> >    umount
> >    rpc.nfsd 16
> 
> The rpc.nfsd 0 alone stopped this complaint and allowed the umount to 
> succeed. Thanks. (Do I really want the last line "rpc.nfsd 16"? After 
> all, I'm trying to turn nfs off.)
> 
> It sounds as if there is a bug here,

It may be the nfsv4 reboot recovey code holding a reference to
/var/lib/nfs/v4recovery/.

> but it's Gentoo nfs init script 
> that's at fault because presumably it should be executing "rpc.nfsd 
> "0 and "exportfs -f" in response to  "/etc/init.d/nfs stop".

I'd think it should be, yes.

--b.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

