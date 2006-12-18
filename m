From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/3] remove extraneous mountlist_add/del calls and
 change remaining ones to use IP addresses
Date: Tue, 19 Dec 2006 09:47:57 +1100
Message-ID: <17799.6813.727114.36028@cse.unsw.edu.au>
References: <4586FD8C.2050602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwRGi-0002Kh-1F
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 14:47:36 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GwRGi-0006jy-9X
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 14:47:37 -0800
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: message from Jeff Layton on Monday December 18
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Thanks for these Jeff.  I've committed them to the nfs-utils git tree.

> 
> Neil, I'm open to respinning this so that it gets called again from the kernel
> caching routines, but I'm not sure how to prevent the rmtab from growing w/o
> bound that way.

The only way I can think of it by adding timestamp information to
rmtab, and ignoring entries older than some timeout.  The kernel
caches have a timeout and refresh regularly so active entries would be
kept up-to-date and inactive entries would appear old.  Any code that
updates rmtab could remove old entries so rmtab wouldn't grow too
much.

It might be worth while if people want to use showmount for NFSv4...

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
