From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: readdir and readdirplus...
Date: Wed, 24 Sep 2003 10:50:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B384016486A6@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A27hQ-0004Rf-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 04:20:48 -0700
Received: from srv-grp-s01.axime.com ([160.92.18.102])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A25MO-0004IV-3Y
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 01:50:56 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I am using a linux 2.4.20+NFS-ALL patches.
my server is a Netapp Filer

I am using NFSv3

what I did not understand is that it's seems that linux does not use =
READDIRPLUS ...=20
is it normal ? in sources I have seen that certain condition should be =
met... but I never see any READDIRPLUS request !!!

thanks
valery


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
