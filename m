From: Olaf Kirch <okir@lst.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 17:07:28 +0200
Message-ID: <200704271707.29862.okir@lst.de>
References: <17958.48121.280256.493824@notabene.brown>
	<17968.18279.424773.589417@notabene.brown>
	<200704261059.50688.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhS2x-00068R-FZ
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:07:43 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhS2y-0004IF-IR
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:07:46 -0700
Received: from [192.168.5.32] (p54a7f41f.dip.t-dialin.net [84.167.244.31])
	(authenticated bits=0)
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l3RF7dLD004187
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 27 Apr 2007 17:07:40 +0200
In-Reply-To: <200704261059.50688.okir@lst.de>
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

On Thursday 26 April 2007 10:59, Olaf Kirch wrote:
> Anyway, I guess in order to prove my point about the sunrpc library
> I should cough up some code to prove it can be done. I'll be uploading
> some patches later tonight or tomorrow.

Okay, here we go. Please have a look at
http://oss.oracle.com/~okir/newrpc/

This makes the client side IPv6 aware, by introducing some concepts
and terminology from TIRPC without pulling in that code wholesale.
(In fact, the only bits I copied from the TIRPC code base were header
files, but that's just because I like to tinker; I guess some things
such as the netconfig stuff might as well be used verbatim, at the
expense of making some code more complicated.)

It hasn't seen much testing; I just confirmed that it still seems to
work with IPv4. The IPv6 side hasn't seen any testing yet.

Please consider this as a proof of concept.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
