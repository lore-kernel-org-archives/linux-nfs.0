From: "Andrew Lee" <andrew@sonysnowie.com>
Subject: nfs mount problem on vxfs
Date: Tue, 9 Jan 2007 14:51:36 -0500 (EST)
Message-ID: <56800.63.119.254.10.1168372296.squirrel@mail.sonysnowie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4N0b-0000hb-6x
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 11:51:45 -0800
Received: from outbound-mail-46.bluehost.com ([69.89.18.15])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1H4N0Z-0008I7-FI
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 11:51:46 -0800
Received: from [127.0.0.1] (helo=box176.bluehost.com)
	by box176.bluehost.com with esmtp (Exim 4.52) id 1H4N0S-0007AJ-Ie
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 12:51:37 -0700
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

I recently upgraded my redhat box to SuSE linux, the kernel version is
2.6.5-7.252-bigsmp

Here is my nfs server version

yast2-nfs-client-2.9.11-23.2
yast2-nfs-server-2.9.9-23.2

I exported 2 directories, one is the /tmp on local reiserfs, and the other
one is a /emc on vxfs (emc disk). I tried multiple nfs clients, the client
can mount the /tmp, but none of them can mount the /emc directory, the
client just hung.

Any idea? is that a bug or some configuration problem on my nfs server?

Thanks.

Andrew

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
