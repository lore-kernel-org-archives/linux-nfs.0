From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Corrupt Data when using NFS on Linux
Date: 28 Oct 2002 21:57:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65vmmgca.fsf@charged.uio.no>
References: <002d01c27ebd$8c017660$2864a8c0@alanw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186GxK-00057w-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 12:57:50 -0800
To: "Alan Witz" <awitz@magstarinc.com>
In-Reply-To: <002d01c27ebd$8c017660$2864a8c0@alanw>
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

>>>>> " " == Alan Witz <awitz@magstarinc.com> writes:

     >           *7.10. File Corruption When Using Multiple Clients*

     >      If a file has been modified within one second of its
     >      previous modification and left the same size, it will
     >      continue to generate the same inode number. Because of
     >      this, constant reads and writes to a file by multiple
     >      clients may cause file corruption. Fixing this bug
     >      requires changes deep within the filesystem layer, and
     >      therefore it is a 2.5 item.

That passage looks pretty confused to me. The inode number is indeed
irrelevant here.

The reason for the problem is that NFS uses the file's mtime and size
in order to determine whether or not another NFS client has written to
the file since it was last opened.

For most NFS servers, the mtime has a resolution of 1 microsecond or
better. Under Linux, however, the mtime has a resolution of 1
second. Hence if your *server* is a Linux machine, then a change by
another client that occurs within 1 second of your last change might
not cause mtime to be updated. Unless this second change also causes
the file size to change, it will appear to your client as if nobody
else has touched the file, and file corruption may follow due to the
fact that the 2 clients' file caches disagree.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
