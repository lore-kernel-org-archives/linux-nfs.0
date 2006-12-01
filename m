From: Olaf Kirch <okir@suse.de>
Subject: Re: several oopses of nfsd in 2.6.16.29
Date: Fri, 1 Dec 2006 10:26:00 +0100
Message-ID: <20061201092559.GE11918@suse.de>
References: <20695426.1164960395196.JavaMail.ngmail@webmail13>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq4ef-0003It-Up
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 01:26:02 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gq4eg-0000vl-Mc
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 01:26:03 -0800
To: linuxkernel@arcor.de
In-Reply-To: <20695426.1164960395196.JavaMail.ngmail@webmail13>
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

On Fri, Dec 01, 2006 at 09:06:35AM +0100, linuxkernel@arcor.de wrote:
> it happened again, but this time without /proc/fs/nfsd mounted.  This is getting on my nerves.
> Please see attached the oopses.  Now I switched to 2.6.16.33.

It doesn't look like this is necessarily nfsd's fault; this looks more
like memory corruption to me.  Something stomped on either the inode or
(less likely) the inode->ops of some file.

I'd suggest building the kernel with slab debugging enabled and
see whether that turns up anything useful.

There's a remote chance this is related to ACLs though, as the
first crash is in an ACL call. Are you using ACLs at all?

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
