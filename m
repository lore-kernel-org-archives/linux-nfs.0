From: =?ISO-8859-1?Q?J=F6rgen_Karlsson?= <jorgen.karlsson@chello.se>
Subject: knsfd - files don't sync to disk
Date: Thu, 16 May 2002 21:43:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE40BF7.1090605@chello.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp2.chello.se ([193.150.195.11])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178R3Q-0007Nk-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 12:36:48 -0700
Received: from chello.se ([213.200.143.211]) by smtp2.chello.se
          (InterMail vK.4.04.00.00 201-232-137 license d2583c0617b67bae473a44216fd3d32d)
          with ESMTP id <20020516193645.MHUF2385.smtp2@chello.se>
          for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 21:36:45 +0200
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

Hi,

We have a serious problem with knfsd and kernel 2.4.17.

When doing a database backup in our linux cluster we have noticed that
a few files are not written to disk properly. The files have zero
file size when checked with the 'ls' command

Several thousands of files are written to the nfs server during a
short period of time.  Average file size is 300-400 bytes.

We have noticed that usually 1-2 out of 3000 files will have their sizes
truncated to 0.

File  system is exported with (rw,sync)

The disk filesystem is ext2.

E.g. this is what is happening:
          - client writes 272 bytes to the server
          - mm/file.c:generic_file_write() returns 272 bytes written
          - fs/nfsd/vfs.c:nfs_write() increments nfsdstats.io_write +=272
             and returns that the write was sucessful.
          - knfsd returns to client that 272 bytes was written.
          - when checking with 'ls' command on server the file size is zero.

Apparently the nfs server lies to the client and the files are not
properly synced/written to disk.

Setting no_wdelay makes no difference.

When running with async set (or sync removed) the problem
disappears (no files have their sizes truncated to zero).

The nfs server is a PIII-700/ 1GB RAM

Any ideas what is going on ?

/Jörgen Karlsson














_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
