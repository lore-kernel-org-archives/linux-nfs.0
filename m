From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Makefile system
Date: Thu, 08 Jul 2004 11:33:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040708153346.342C512FF4@citi.umich.edu>
References: <20040623080942.GJ21651@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Robert Schwebel <robert@schwebel.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BiauF-0001X4-2l
	for nfs@lists.sourceforge.net; Thu, 08 Jul 2004 08:33:51 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BiauE-00026P-Os
	for nfs@lists.sourceforge.net; Thu, 08 Jul 2004 08:33:51 -0700
To: nfs@lists.sourceforge.net
In-reply-to: Your message of "Wed, 23 Jun 2004 10:09:42 +0200."
             <20040623080942.GJ21651@pengutronix.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Use of the autotools would simplify CITI's patches for NFSv4.  Is it =

likely these autotools changes will be incorporated into the package =

such that we could take advantage of them?

> Hi, =

> =

> While working on the PTXdist build system we noticed that the nfs utils=
'
> Makefile system is significantly broken when it comes to cross
> compiling. After hacking the old code for some hours we had the
> impression that it was so seriously broken that we re-wrote the
> makefiles with the GNU autotools.
> =

> It doesn't make much sense to post a patch - this would probably be
> larger than the packet itself. As a base for further discussion, here's=

> our version: =

> =

> 	http://www.pengutronix.de/software/nfs-utils/
> =

> This version does the following things:
> =

> 	* remove all old Makefiles and replace them with proper
> 	  Makefile.am files
> 	* tested for cross compilation
> 	* tested for out-of-tree builds
> 	* currently the Debian/Red Hat support is missing
> 	  (might be something for somebody who knows what he =

> 	  is doing)
> =

> Any comments are welcome...



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
