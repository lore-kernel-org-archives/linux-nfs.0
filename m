From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Build failure
Date: Fri, 8 Jun 2007 12:47:47 +0200
Message-ID: <20070608104747.GA3475@uio.no>
References: <20070608102457.GA3154@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hwc0T-0005oi-0h
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 03:47:49 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hwc0U-00036k-VV
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 03:47:52 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1Hwc0R-0006Mh-G3
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 12:47:47 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1Hwc0R-0000uX-00
	for <nfs@lists.sourceforge.net>; Fri, 08 Jun 2007 12:47:47 +0200
In-Reply-To: <20070608102457.GA3154@uio.no>
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

On Fri, Jun 08, 2007 at 12:24:57PM +0200, Steinar H. Gunderson wrote:
> Today nfs-utils stopped building for me, probably due to a libc update or
> something. The failed part was, from support/include/nfs/nfs.h:

Nevermind; I upgraded my build environment, and the problem went away. I
guess something was broken on my side.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
