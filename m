From: Stefan Palme <kleiner@hora-obscura.de>
Subject: possible solution for userid mapping problem
Date: Wed, 13 Dec 2006 10:10:19 +0100
Message-ID: <1166001020.26144.14.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuQ8H-0006T6-25
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 01:10:33 -0800
Received: from moutng.kundenserver.de ([212.227.126.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GuQ8F-0000MI-H8
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 01:10:34 -0800
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 0088058400D
	for <nfs@lists.sourceforge.net>; Wed, 13 Dec 2006 10:10:22 +0100 (CET)
Received: from devel.office.ancoso-development.de
	(p54B94F07.dip0.t-ipconnect.de [84.185.79.7])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 7836A584003
	for <nfs@lists.sourceforge.net>; Wed, 13 Dec 2006 10:10:19 +0100 (CET)
To: nfs@lists.sourceforge.net
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


Hi all,

I have an NFS server exporting a directory to another machine. This
directory is used by an application server on the NFS server host.
The application server runs under a special uid/gid, and the exported
directory is owned and only accessible by this special user.

The same application server runs on the NFS client host, and I want
this application server to use the same directory via NFS 
(from application server's point of view there is no problem using
a "shared directory" in this context).

The only problem: the special user used for the application server
has different uids/gids on both hosts. Since I had to learn, that 
there is no "official" way to map different uids, I think about
mapping *all* userids to the application servers userid as "anonuid".

So on the NFS server the exports file would contain

  /var/lib/appserver/data   1.2.3.4/32(rw,async,all_squash,anonuid=123,anongid=123)

(where the application servers special user account has
uid=gid=123).

The NFS client would mount this directory normally via

  mount -t nfs 4.3.2.1:/var/lib/appserver/data /var/lib/appserver/data

So I hope to give the NFS-clients-application-server-user (uid=gid=456)
access to the data of the NFS-servers-application-server-user (uid=gid=123).

>From the technical point of view this seems to work (I've tested this
setup successfully). My actual question is, if it is *nice* to do
this (because it seems to me like a kind of hack), and if there is maybe
a better solution for this?

TIA
Regards
-stefan-



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
