From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] 2.6 open(O_EXCL) sets silly mtime
Date: Tue, 20 Apr 2004 10:18:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040420081822.GB14756@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFqSZ-0003RN-UH
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 01:18:27 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BFqSZ-0000rn-Ef
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 01:18:27 -0700
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 060504937E2
	for <nfs@lists.sourceforge.net>; Tue, 20 Apr 2004 10:18:23 +0200 (CEST)
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


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

the attached patch (relative to 2.6.5) is required to make sure a file
created with O_EXCL gets the proper mtime.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-o-excl-mtime

--- linux-2.6.5/fs/nfs/nfs3proc.c.excl	2004-04-19 14:35:47.000000000 +0200
+++ linux-2.6.5/fs/nfs/nfs3proc.c	2004-04-19 16:55:50.000000000 +0200
@@ -375,6 +375,9 @@
 		};
 		dprintk("NFS call  setattr (post-create)\n");
 
+		if (!(sattr->ia_valid & ATTR_MTIME_SET))
+			sattr->ia_valid |= ATTR_MTIME;
+
 		/* Note: we could use a guarded setattr here, but I'm
 		 * not sure this buys us anything (and I'd have
 		 * to revamp the NFSv3 XDR code) */

--uAKRQypu60I7Lcqm--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
