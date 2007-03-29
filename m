From: Toni Zimmer <T.Zimmer@science-computing.de>
Subject: Re: NFSv3-Client creates empty files on AIX 5.1/5.3 file
	server
Date: Thu, 29 Mar 2007 10:19:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0703291005150.31576@bender.science-computing.de>
References: <Pine.LNX.4.61.0703281442310.31576@bender.science-computing.de>
	<1175102015.6162.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWprP-00017w-BF
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 01:19:55 -0700
Received: from smtp1.belwue.de ([129.143.2.12])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWprQ-00031D-6F
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 01:19:57 -0700
Received: from mx4.science-computing.de (mx4.science-computing.de
	[193.197.16.30]) by smtp1.belwue.de with ESMTP id l2T8JpGN008960
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 10:19:51 +0200 (MEST)
	env-from (T.Zimmer@science-computing.de)
Received: from localhost (localhost [127.0.0.1])
	by scmail.science-computing.de (Postfix) with ESMTP id 5FE0671A9EFA
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 10:19:51 +0200 (CEST)
Received: from scmail.science-computing.de ([127.0.0.1])
	by localhost (obitest [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 09178-08 for <nfs@lists.sourceforge.net>;
	Thu, 29 Mar 2007 10:19:46 +0200 (CEST)
Received: from bender.science-computing.de (bender.science-computing.de
	[10.10.24.25])
	by scmail.science-computing.de (Postfix) with ESMTP id 53F9671A9F10
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 10:19:46 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by bender.science-computing.de (Postfix) with ESMTP id 3EDE34128F27
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 10:19:46 +0200 (CEST)
In-Reply-To: <1175102015.6162.27.camel@heimdal.trondhjem.org>
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

On Wed, 28 Mar 2007, Trond Myklebust wrote:

>
> There is a known issue with various BSD servers (including apparently
> AIX) refusing to allow anyone other than the file owner change the
> mtime/ctime on files (try doing 'touch foo' where 'foo' is one of the
> files you are seeing problems with). This breaks open(O_TRUNC), which is
> supposed to always change the mtime+ctime (whether or not the file size
> changed).
>
> Cheers
>  Trond

Hi Trond,

thanks for your reply.
We tried to "touch" the problematic files:

> id
uid=50099(user2) gid=50079(group1) groups=50079(group1)

> stat sctestfile02
   File: `sctestfile02'
   Size: 8               Blocks: 8          IO Block: 8192   regular file
Device: 1dh/29d Inode: 25650       Links: 1
Access: (0660/-rw-rw----)  Uid: (50124/ user1)   Gid: (50079/group1)
Access: 2007-03-29 10:04:40.352616605 +0200
Modify: 2007-03-29 10:10:07.552617379 +0200
Change: 2007-03-29 10:10:07.576410231 +0200

> touch sctestfile02

> stat sctestfile02
   File: `sctestfile02'
   Size: 8               Blocks: 8          IO Block: 8192   regular file
Device: 1dh/29d Inode: 25650       Links: 1
Access: (0660/-rw-rw----)  Uid: (50124/ user1)   Gid: (50079/group1)
Access: 2007-03-29 10:13:11.582617023 +0200
Modify: 2007-03-29 10:13:11.582617023 +0200
Change: 2007-03-29 10:13:11.582617023 +0200
> ls -lrt sctestfile02
-rw-rw---- 1 user1 group1 8 2007-03-29 10:13 sctestfile02


So the file is okay now and I don't see the relation between the two 
issues because "user2" is allowed to change the mtime and the ctime...


Greetings

Toni

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
