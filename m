From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs/mmap/rename file corruption
Date: Thu, 28 Aug 2003 10:04:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16206.3062.480403.590086@charged.uio.no>
References: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
	<shs1xv6ftp9.fsf@charged.uio.no>
	<20030828121410.4ccc4b45.mbp@sourcefrog.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sNOO-0004QJ-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 07:04:52 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sNOJ-0005t4-K8
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 07:04:47 -0700
To: Martin Pool <mbp@sourcefrog.net>
In-Reply-To: <20030828121410.4ccc4b45.mbp@sourcefrog.net>
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

>>>>> " " == Martin Pool <mbp@sourcefrog.net> writes:


     >     In order to perform this check, the server must include
     >     some information about the location of the file in the
     >     "filehandle" that is given to the client.  This can cause
     >     problems with accessing files that are renamed while a
     >     client has them open (though in many simple cases it will
     >     still work).

     > In this case, the file is not still open at the time it is
     > renamed.  It just still has some dirty pages in the client's
     > memory.

That is the same as being 'open' for the purposes of the above
paragraph.

    >> Without the latter option enabled, I would indeed expect the
    >> behaviour that you describe.

     > It seems a bit unfortunate that we can get corruption unless a
     > special option is set.  Will it work on non-Linux nfs servers?

Yes. 'subtree checking' is a Linux-only concept. Most servers just
open their files by inode number and leave it at that.

     > Wouldn't it still be possible to get the client to flush data
     > out before renaming it?  I tried naively calling nfs_flush_file
     > before renaming but that didn't seem to do it.

mmap() is 'special': there are all sorts of silly races possible, and
many of them appear to lie deep in the mm layer. If you want to
trigger some really nasty ones, try playing with mmap() +
truncate()....

In principle, you could get what you want by calling the combination

filemap_fdatasync(inode->i_mapping);
nfs_wb_all(inode);
filemap_fdatawait(inode->i_mapping);

like we do in the file locking code. However that too appears to be
race prone due to races with the swap code.

In any case, doctoring the client in order to get around a bug in the
server is not usually my first choice...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
