From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: Uid/Gid mapping
Date: Tue, 9 Jul 2002 09:46:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207091346.g69DkKX04527@agora.fsl.cs.sunysb.edu>
References: <001601c2272a$50f8d670$230d0dc3@Athlon>
Cc: nfs@lists.sourceforge.net, joseph@cs.sunysb.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fslgw.cs.sunysb.edu ([130.245.254.6] helo=fsl-gw.fsl.cs.sunysb.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RvP5-0004x8-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 06:51:43 -0700
To: "Paolo Marini" <paolom@prisma-eng.it>
In-Reply-To: Your message of "Tue, 09 Jul 2002 11:23:39 +0200."
             <001601c2272a$50f8d670$230d0dc3@Athlon>
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

In message <001601c2272a$50f8d670$230d0dc3@Athlon>, "Paolo Marini" writes:
> I have read, on the old exports man page, that there is an option to specify
> the mapping between client UID/GID and server UID/GID. It appears to be no
> more in the nfs code. Is there any other way to do this mapping in a static
> way ?

There are unofficial 2.4.x patches that support range-mapping and more
(cloaking) in

	ftp://ftp.fsl.cs.sunysb.edu/pub/enf/

A paper on this project, entitled "Enhancing NFS Cross-Administrative Domain
Access" was presented at FREENIX last month, and is available from

	http://www.fsl.cs.sunysb.edu/papers/

Cheers,
Joe and Erez.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
