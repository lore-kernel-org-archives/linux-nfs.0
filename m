From: Martin Pool <mbp@sourcefrog.net>
Subject: nfs/mmap/rename file corruption
Date: Thu, 28 Aug 2003 11:03:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sBC5-00004v-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 18:03:21 -0700
Received: from sngrel4.hp.com ([192.6.86.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sBC2-0000dN-NT
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 18:03:18 -0700
Received: from XAUBRG2.AUS.HP.COM (xaubrg2.aus.hp.com [15.23.69.43])
	by sngrel4.hp.com (Postfix) with SMTP id A24746B
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 09:03:16 +0800 (SST)
Received: from localhost ([127.0.0.1] helo=vexed)
	by vexed with smtp (Exim 3.36 #1 (Debian))
	id 19sBBx-0003Jj-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 11:03:13 +1000
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

There is a fairly easily reproducible bug in NFS in 2.4.22 that can
cause files to read back as full of nulls.  I have a tcpdump that
shows what is going wrong. 

Gavrie Philipson reported corruption happening when distcc and ccache
are used together with the cache on NFS.

  http://lists.samba.org/pipermail/distcc/2003q3/001556.html

To reproduce the bug you need to just install ccache 2.2 and distcc
2.10.1.  Set CCACHE_DIR to an empty directory on an NFS filesystem
mounted with default/rw options.  Build a file with a command like
this:

  ccache distcc -c ./hello.c

The first (only the first) time that you run this, the output file
(hello.o) will be the correct size, but contain only \0 bytes.

What is basically happening here is

 - ccache runs distcc with output to a temporary file
 - distcc opens, mmaps, writes to, munmaps, and closes the temporary
   file
 - distcc exits
 - ccache renames the temporary file to its proper location in the
   ccache
 - ccache opens the file read only, and reads from it

ccache ought to see the proper contents as written by mmap, but when
the cache is on NFS it just sees \0s.  It works correctly and reliably
on reiserfs and ext3.  However, if you look at the file ccache was
trying to read a second later then it seems to have the right
contents.

I tried writing a standalone test case but I couldn't reproduce it,
perhaps because of some timing issue.  It is quite reproducible both
on my machine and Gavrie's.

If distcc is configured to not use mmap for writing, the problem is
hidden.  

A tcpdump of the problem is available here:

 
http://distcc.samba.org/ftp/distcc/misc/mmap-bug/nfs-20030827T1351.pcap.gz

Here are the significant bits:

frame 79

   renames tmp.hash.vexed.7897.o to the final object filename,
   cbfc5ca42b1a693a5bca9bb8b23c5b-17387

frame 105

   also frame 107

   look up a filehandle for the final object filename, and gets the
   hash 0xed8222404

frame 115

   reads back from the final object file, 0xed8222404

frame 116

   is the reply to the read and it is full of nulls

frame 127 

   writes the ELF output into the temporary object file,
   tmp.hash.vexed.7897.o, which has file hash 0xf27c2204.

The problem is that the NFS client tries to read from the destination
file before it has written to the temporary file!  Frame 127 is far
too late.

It seems to me like there are two possible solutions: either flush out
all cached data for a file before it's renamed, or make the rename
smart enough to 'take over' any data cached under an old name.  To me
the first seems more robust if a little slower.

You can see something similar going on in this NFS log:

 
http://distcc.samba.org/ftp/distcc/misc/mmap-bug/nfsdebug-20030827T1609.log.gz

The flush(b/49777) call comes long after the rename and the attempt to
read from the new file.

I'll try to draft a patch for this.

-- 
Martin


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
