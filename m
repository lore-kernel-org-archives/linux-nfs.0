From: "Charlie Brownell" <cbrownell@simstar.com>
Subject: Exporting samba mounts through NFS.
Date: Tue, 23 Jul 2002 14:40:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <42997589360DBA4D931A5DE531290D06246597@nobelium.simstar.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.204.48.1] (helo=nobelium.simstar.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X4aU-0004PT-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 11:40:46 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hey guys,

   I'm going nuts with this. I'm trying to give a Solaris box access to =
some windows files, but NFS on the Linux box in the middle isn't =
cooperating. The smbmount is fine, but I cannot share the smbmount =
directly through NFS, nor will anything show up in the mounted directory =
when I share it's parent. I've also tried NFS sharing and NFS mount and =
got the same results.

   I've seen talk of a --re-export option for mountd, but it doesn't =
seem to be supported anymore. Is there a way to accomplish this?

Thanks,
Charlie


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
