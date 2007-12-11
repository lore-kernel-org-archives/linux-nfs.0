From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Tue, 11 Dec 2007 13:20:37 -0800
Message-ID: <1197408037.1215.31.camel@dyn9047022153>
References: <20070905204628.GD29582@fieldses.org>
	<18246.16373.177320.570040@notabene.brown>
	<1196722262.1215.5.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, ffilz@us.ibm.com,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54362 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbXLKVsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2007 16:48:15 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J2CxZ-0008MT-9T
	for linux-nfs@vger.kernel.org; Wed, 12 Dec 2007 08:48:13 +1100
In-Reply-To: <1196722262.1215.5.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, I've looked at this issue some more. The crossmnt and nohide options
work correctly so long as security negotiation isn't required to cross
the mount point (whether the mount command provides the correct set of
security flavors or not). If the crossmnt export option is provided in
this case (whether or not nohide is specified on the child export), an
ls of the /mnt/home ends up with the results from an ls of /mnt. If the
crossmnt option is not specified on the parent but nohide is specified
on the child, an ls -l of /mnt results in slightly different contents
while an ls -l of /mnt/home results in the contents of the hidden
directory on the parent export.

These behaviors seem undesirable, but perhaps not worth eliminating
since they do represent something unsupported by the old format which is
deprecated in favor of the new format where everything works just fine.

Frank Filz



-------------------------------------------------------------------------
SF.Net email is sponsored by:
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

