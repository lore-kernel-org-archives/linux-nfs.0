From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API change...)
Date: Mon, 30 Sep 2002 20:57:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15768.40630.512787.879557@charged.uio.no>
References: <15768.39196.468797.249573@charged.uio.no>
	<20020930195235.P18377@parcelfarce.linux.theplanet.co.uk>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    Marcelo Tosatti <marcelo@conectiva.com.br>,
    Chuck Lever <cel@netapp.com>,
    Linux Kernel <linux-kernel@vger.kernel.org>,
    Linux FSdevel <linux-fsdevel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17w5kU-0006RZ-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 11:58:30 -0700
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20020930195235.P18377@parcelfarce.linux.theplanet.co.uk>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Matthew Wilcox <willy@debian.org> writes:

    >> -static int blkdev_direct_IO(int rw, struct inode * inode,
    >> struct kiobuf * iobuf, unsigned long blocknr, int blocksize)
    >> +static int blkdev_direct_IO(int rw, struct file * filp, struct
    >> kiobuf * iobuf, unsigned long blocknr, int blocksize) {
    >> + struct inode * inode =
    >>  	filp->f_dentry->d_inode->i_mapping->host;
    >> return generic_direct_IO(rw, inode, iobuf, blocknr, blocksize,
    >> blkdev_get_block); }
    >>

     > isn't that two dereferences more than necessary for a local
     > filesystem?

IIRC this is an issue with block filesystems: the i_mapping->host may
differ from d_inode.

It is in any case just the exact same dereference that is being made
in the current version of generic_file_direct_IO(). The API change
simply moves this dereference down into the filesystem code.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
