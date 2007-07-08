From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Status of mount.nfs
Date: Sun, 8 Jul 2007 21:16:40 +0200
Message-ID: <20070708191640.GA13962@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: lamont@debian.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7cFP-0004vi-Fe
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 12:16:44 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I7cFR-0005Pd-0l
	for nfs@lists.sourceforge.net; Sun, 08 Jul 2007 12:16:45 -0700
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

util-linux 2.13 drops support for NFS mounts:

  Release highlights:
  ------------------
   mount(8) doesn't include NFS client code anymore. Don't forget to
   install nfs-utils 1.1.0 or newer with /sbin/[u]mount.{nfs,nfs4}.

However, the last I can find in nfs-utils changelog about this is:

  commit 99414bd3eecf93f23c378d3bb3d45bc98f364abc
  Author: Neil Brown <neilb@suse.de>
  Date:   Sat Jul 8 09:41:58 2006 +1000
  
      Disable building/installing mount.nfs by default.
      
      mount.nfs does not yet support 'user' option and some others.
      To make it support this we need to make it setuid-root, and
      some security isses need to be resolved before that can be done
      safely.

What's the current recommendation for distributions with regard to NFS
mounting?

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
