From: Antoine Jacoutot <ajacoutot@lphp.org>
Subject: nfssvc: Permission denied
Date: Fri, 15 Nov 2002 15:20:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1037370050.3dd502c24af77@webmail.lphp.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from apastourelles-107-1-18-63.abo.wanadoo.fr ([81.49.132.63] helo=mail.lphp.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ChL7-0005fQ-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Nov 2002 06:20:57 -0800
Received: from localhost (APastourelles-107-1-18-63.abo.wanadoo.fr [81.49.132.63])
	by mail.lphp.org (Postfix) with ESMTP id 5E11C8FCB7
	for <nfs@lists.sourceforge.net>; Fri, 15 Nov 2002 15:20:50 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hi, =20
=20
I'm using NFS under Gentoo Linux with kernel-2.4.19.=20
When starting nfs server with nfs init script (from nfs-utils), I get the=
 =20
following message: =20
=20
/etc/init.d/nfs start =20
[ok ] * Starting NFS statd... =20
[ ok ] * Starting NFS rquotad... =20
[ ok ] * Starting NFS daemon... =20
nfssvc: Permission denied =20
* Error starting NFS daemon =20
[ !! ] =20
* Starting NFS mountd... =20
=20
The modules are correctly loaded: =20
nfsd 61136 0 (autoclean) =20
lockd 44080 0 (autoclean) [nfsd] =20
sunrpc 60796 0 (autoclean) [nfsd lockd] =20
=20
This error is happening on all my servers, whether the nfs is user-space =
=20
or kernel-space. =20
=20
There's nothing in the logs except someting about the portmapper (in=20
auth.log): =20
Oct 7 07:03:09 srv01 portmap[29402]: connect from 127.0.0.1 to set(nfs): =
=20
request from unprivileged port =20
Oct 7 07:03:09 srv01 portmap[21158]: connect from 127.0.0.1 to unset(nfs)=
: =20
request from unprivileged port =20
Oct 7 07:04:40 srv01 portmap[1765]: connect from 127.0.0.1 to set(nfs):=20
request =20
from unprivileged port =20
=20
Portmap is running and I have nfs-utils-0.3.3-r1.=20
=20
Thanks in advance if you have any clue.=20
I've search Google and didn't find anything usefull (this errors appears =
to=20
happen on old Linux kernels, but I'm using the lastest stable).=20
=20
-- =20
Antoine Jacoutot=20
Gentoo Linux=20
ajacoutot@lphp.org=20
http://www.lphp.org=20
=20
=20
=20


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
