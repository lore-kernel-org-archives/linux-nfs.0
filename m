From: Maurice Volaski <mvolaski-Q33DkHiyi7z2fBVCVOL8/A@public.gmane.org>
Subject: Re: [NFS] the infamous" device is busy" bug
Date: Sat, 14 Jun 2008 01:20:26 -0400
Message-ID: <p06240405c4790372e350@[129.98.90.227]>
References: <mailman.32188.1213350650.3945.nfs@lists.sourceforge.net>   
	<p06240404c478afa53f34@[129.98.90.227]>
	<53236.192.168.1.70.1213405151.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49032 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbYFNFU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2008 01:20:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K7OC7-0007jN-0J
	for linux-nfs@vger.kernel.org; Sat, 14 Jun 2008 15:20:55 +1000
In-Reply-To: <53236.192.168.1.70.1213405151.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>should release it, though if there are active clients, one could grab it
>again very quickly.
>Alternately
>    rpc.nfsd 0
>    exportfs -f
>    umount
>    rpc.nfsd 16

The rpc.nfsd 0 alone stopped this complaint and allowed the umount to 
succeed. Thanks. (Do I really want the last line "rpc.nfsd 16"? After 
all, I'm trying to turn nfs off.)

It sounds as if there is a bug here, but it's Gentoo nfs init script 
that's at fault because presumably it should be executing "rpc.nfsd 
"0 and "exportfs -f" in response to  "/etc/init.d/nfs stop".
-- 

Maurice Volaski, mvolaski-Q33DkHiyi7z2fBVCVOL8/A@public.gmane.org
Computing Support, Rose F. Kennedy Center
Albert Einstein College of Medicine of Yeshiva University

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

