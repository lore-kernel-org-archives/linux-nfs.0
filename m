From: "Amir Hermelin" <amir@montilio.com>
Subject: Mount wsize and sync options
Date: Wed, 19 May 2004 12:35:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00de01c43d8d$0676f980$0f01a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQNUM-0005ei-Nw
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 02:35:50 -0700
Received: from sphere.barak.net.il ([212.150.48.98])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BQNUM-0004rb-A2
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 02:35:50 -0700
Received: from CARTMAN ([62.90.35.123]) by sphere.barak.net.il
          (InterMail vK.4.04.00.00 201-232-137 license e5bc39f1001e7dfa47fa92d56cd12779)
          with ESMTP id <20040519093444.DNLS6118.sphere@CARTMAN>
          for <nfs@lists.sourceforge.net>; Wed, 19 May 2004 12:34:44 +0300
To: <nfs@lists.sourceforge.net>
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
I run an nfs server (RH9, kernel 2.4.20), and have experienced a =
behavior
with the wsize mount option that I have no explanation for. It appears =
that
when I use the sync option, the wsize is ignored (in default v3 UDP =
mount)
and is always 4k.

Maybe someone in the group can explain them to me or refer me to the =
'rules'
for using wsize and sync.

Thanks,
Amir.



-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
