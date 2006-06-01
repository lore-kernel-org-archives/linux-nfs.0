From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Fri, 2 Jun 2006 00:39:51 +0200
Message-ID: <20060601223951.GB1227@uio.no>
References: <20060601155929.GA890@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlvpT-0002yb-QI
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:39:48 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlvpS-0007fr-Gp
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:39:46 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FlvpQ-0005oS-UO
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:39:46 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:dc03:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1FlvpN-0005IB-Oc
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 00:39:42 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1FlvpX-0000LD-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Jun 2006 00:39:51 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20060601155929.GA890@uio.no>
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

On Thu, Jun 01, 2006 at 05:59:29PM +0200, Steinar H. Gunderson wrote:
> So, over to the patches -- they are all against 1.0.8, and can be found at
> http://people.debian.org/~sesse/nfs-utils-patches/ :

I added a new one:

 - fix_manpage_errors.diff: Fixes a few errors from man in the idmapd.conf
   man page. (I don't know of any other man pages giving errors; "man -l
   foo.man >/dev/null" is usually the simplest way to check for these.)

/* Steinar */
-- 
Homepage: http://www.sesse.net/


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
