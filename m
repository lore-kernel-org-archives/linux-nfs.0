From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: nfs unlink perf !
Date: Mon, 12 Aug 2002 14:08:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E214@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes7.atos-group.com ([160.92.18.56] helo=hermes7.axime.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eDzv-0004sM-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 05:08:35 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I am testing an application which to a lot of link/unlink

server is a NetApp filer, client is linux 2.4.19+nfs patches.

under load it seems that the unlink call is very long when all over calls
response time seems to be OK.
is there any problems with the unlink code ?

thanks



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
