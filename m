From: Robert Schwebel <robert@schwebel.de>
Subject: Makefile system
Date: Wed, 23 Jun 2004 10:09:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040623080942.GJ21651@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Benedikt Spranger <b.spranger@pengutronix.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bd2pT-0002K1-Fw
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 01:09:59 -0700
Received: from amalthea.dnx.de ([193.108.181.146] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bd2pT-0001v4-0f
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 01:09:59 -0700
Received: from metis.pengutronix.de ([213.252.143.165]:55192)
	by amalthea.dnx.de with asmtp (Exim 4.34)
	id 1Bd2pC-0001gi-9j
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 10:09:54 +0200
To: nfs@lists.sourceforge.net
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

Hi, 

While working on the PTXdist build system we noticed that the nfs utils'
Makefile system is significantly broken when it comes to cross
compiling. After hacking the old code for some hours we had the
impression that it was so seriously broken that we re-wrote the
makefiles with the GNU autotools.

It doesn't make much sense to post a patch - this would probably be
larger than the packet itself. As a base for further discussion, here's
our version: 

	http://www.pengutronix.de/software/nfs-utils/

This version does the following things:

	* remove all old Makefiles and replace them with proper
	  Makefile.am files
	* tested for cross compilation
	* tested for out-of-tree builds
	* currently the Debian/Red Hat support is missing
	  (might be something for somebody who knows what he 
	  is doing)

Any comments are welcome...

Robert
-- 
 Dipl.-Ing. Robert Schwebel | http://www.pengutronix.de
 Pengutronix - Linux Solutions for Science and Industry
   Handelsregister:  Amtsgericht Hildesheim, HRA 2686
     Hornemannstraﬂe 12,  31137 Hildesheim, Germany
    Phone: +49-5121-28619-0 |  Fax: +49-5121-28619-4


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
