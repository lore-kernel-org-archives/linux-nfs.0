From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: 25 Oct 2002 19:23:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssmyuqvp9.fsf@charged.uio.no>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1858BE-0007w8-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 10:23:28 -0700
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021025.185234.08315285.taka@valinux.co.jp>
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

>>>>> " " == Hirokazu Takahashi <taka@valinux.co.jp> writes:


    >> In particular, I think it would be good to use 'struct xdr_buf'
    >> from sunrpc/xdr.h instead of svc_buf.  This is what the nfs
    >> client uses and we could share some of the infrastructure.

     > I just realized it would be hard to use the xdr_buf as it
     > couldn't handle data in a socket buffer. Each socket burfer
     > consists of some non-page data and some pages and each of them
     > might have its own offset and length.

Then the following trivial modification would be quite sufficient

struct xdr_buf {
        struct list_head list;          /* Further xdr_buf */
        struct iovec    head[1],        /* RPC header + non-page data */
                        tail[1];        /* Appended after page data */

        struct page **  pages;          /* Array of contiguous pages */
        unsigned int    page_base,      /* Start of page data */
                        page_len;       /* Length of page data */

        unsigned int    len;            /* Total length of data */

};

With equally trivial fixes to xdr_kmap() and friends. None of this
needs to affect existing client usage, and may in fact be useful for
optimizing use of v4 COMPOUNDS later.
(I was wrong about this BTW: being able to flush out all the dirty
pages in a file to disk using a single COMPOUND would indeed be worth
the trouble once we've managed to drop UDP as the primary NFS
transport mechanism. For one thing, you would only tie up a single
nfsd thread when writing to the file)

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
