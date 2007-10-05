From: Valdis.Kletnieks@vt.edu
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Fri, 05 Oct 2007 13:30:10 -0400
Message-ID: <30494.1191605410@turing-police.cc.vt.edu>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1207890945=="
Cc: Peter Staubach <staubach@redhat.com>, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Pierre Ossman <drzeus-list@drzeus.cx>,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Idr1L-0003tj-K7
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:31:27 -0700
Received: from turing-police.cc.vt.edu ([128.173.14.107])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Idr1N-0008Jw-Gv
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:31:32 -0700
In-Reply-To: Your message of "Thu, 04 Oct 2007 10:00:50 EDT."
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1207890945==
Content-Type: multipart/signed; boundary="==_Exmh_1191605410_2884P";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit

--==_Exmh_1191605410_2884P
Content-Type: text/plain; charset=us-ascii

On Thu, 04 Oct 2007 10:00:50 EDT, Trond Myklebust said:

> How about a boot/module parameter to turn it on or off?
> 
> I don't see any point in having a sysctl for something like this: either
> you have legacy applications or you don't. It is not something that you
> switch off as you go off to lunch.

How does Joe Sysadmin tell if he has an affected legacy app or not?

(The obvious "try it and see what breaks" is a non-starter for many places,
because you too easily end up in a loop of "enable it, find 4-5 show stoppers,
turn it off, fix them, lather rinse repease".  Been there, done that, got
the tshirt - a project I got dragged into involves a large storage array that
appears to insist on exporting 64-bit stuff, and a large farm of clients that
are very 64-bit unclean....)

--==_Exmh_1191605410_2884P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHBnSicC3lWbTT17ARAguhAJ4yFFwmHh6NzutHLK6SsMd4NATjhACeJysn
kycLaBtXZeeZfLAErtMYu1E=
=VK65
-----END PGP SIGNATURE-----

--==_Exmh_1191605410_2884P--


--===============1207890945==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1207890945==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1207890945==--
