From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Function not implemented
Date: Wed, 10 Sep 2003 11:20:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030910152006.GC3938@perlsupport.com>
References: <LOBBJFHFAIJCHENJILKBOEJDMAAA.robert@pawlowicz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19x6l5-0003ZR-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Sep 2003 08:19:51 -0700
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19x6l4-0007jo-Up
	for nfs@lists.sourceforge.net; Wed, 10 Sep 2003 08:19:50 -0700
To: Robert Pawlowicz <robert@pawlowicz.com>
In-Reply-To: <LOBBJFHFAIJCHENJILKBOEJDMAAA.robert@pawlowicz.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

According to Robert Pawlowicz:
> All the daemons start up fine except for nfsd which doesn't start & gives me
> the message:
> 
> server.address.com:/var/www: Function not implemented

You don't have NFSD enabled in your kernel, most likely.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
