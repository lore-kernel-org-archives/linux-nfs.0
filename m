From: Omri Schwarz <ocschwar@MIT.EDU>
Subject: Linux & RPC_GSS with NFS version 3
Date: Wed, 2 May 2007 15:40:16 -0400 (EDT)
Message-ID: <Pine.GSO.4.64L.0705021534300.16975@biohazard-cafe.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjKh1-0002lI-4g
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:40:52 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjKh2-0007bR-FM
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:40:53 -0700
Received: from biscayne-one-station.mit.edu ([18.7.7.80])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1HjKgp-0008S9-Dx
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:40:41 -0700
Received: from outgoing.mit.edu (OUTGOING-AUTH.MIT.EDU [18.7.22.103])
	by biscayne-one-station.mit.edu (8.13.6/8.9.2) with ESMTP id
	l42JeH7J026066
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 15:40:17 -0400 (EDT)
Received: from biohazard-cafe.mit.edu (BIOHAZARD-CAFE.MIT.EDU [18.7.18.67])
	(authenticated bits=56)
	(User authenticated as ocschwar@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.13.6/8.12.4) with ESMTP id l42JeHEB028145
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 15:40:17 -0400 (EDT)
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

Hi, all. I am trying to get Fedora Coure 6 machines to talk
NFS 3 to each other with sec=krb5, and for the moment,
though I have gotten them to talk over other GSSAPI-enabled
services (ssh, imap, ftp, smtp and NFS 4), NFS 3 fails.
The server says
"""
mountd: MNT3(/export) called
mountd: mount request from unknown host 18.75.0.50 for /export (/export) 
""".

Going deeply enough I can see that mountd (1.0.10-7.fc6)
continues to check IP addresses against the string "gss/krb5" instead of
doing the right thing and having a chat with svcgssd.
I'll be gratefull for any help in getting mountd to DTRT here.

Regards,


Omri Schwarz --- ocschwar@mit.edu
Timeless wisdom of biomedical engineering: "Noise is principally
due to the presence of the patient." -- R.F. Farr


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
