From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Status of NFS over IPv6
Date: Fri, 29 Jun 2007 14:37:47 +0200
Message-ID: <20070629123747.GA1034@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4FjS-00058e-Tn
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 05:37:50 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4FjV-0001uh-4S
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 05:37:54 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1I4FjP-0006Ci-Bn
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 14:37:47 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1I4FjP-0000H9-00
	for <nfs@lists.sourceforge.net>; Fri, 29 Jun 2007 14:37:47 +0200
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

Hi,

What's the current status of NFS over IPv6 in Linux? There are HOWTOs out
there, but most patches seem to be against old kernel versions, and
completely unable to run both client and server from the same kernel tree.
Additionally, I see mentions of replacements for portmap, but no clear
upstream URL or updated versions anywhere. Also, there seems to be a separate
git tree maintained by Chuck Lever, but gitweb hides any special patches it
might have in tons of upstream patches.

I'd very much like to be able to sew all of this together at some point,
but it's very hard to get a decent overview of it all. Does anyone have a
"current status" or "plans for the near feature" summary?

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
