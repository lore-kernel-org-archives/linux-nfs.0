From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Sat, 26 Oct 2002 12:26:31 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021026.122631.41629285.taka@valinux.co.jp>
References: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
	<shssmyuqvp9.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185HiD-0007y8-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 20:34:09 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <shssmyuqvp9.fsf@charged.uio.no>
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

Hello,

> Then the following trivial modification would be quite sufficient

Yes, it looks good as it's rare to use two or more xdr_bufs.
We can allocate extra xdr_bufs dynamically.

> struct xdr_buf {
>         struct list_head list;          /* Further xdr_buf */
>         struct iovec    head[1],        /* RPC header + non-page data */
>                         tail[1];        /* Appended after page data */
> 
>         struct page **  pages;          /* Array of contiguous pages */
>         unsigned int    page_base,      /* Start of page data */
>                         page_len;       /* Length of page data */
> 
>         unsigned int    len;            /* Total length of data */
> 
> };
> 
> With equally trivial fixes to xdr_kmap() and friends. None of this
> needs to affect existing client usage, and may in fact be useful for
> optimizing use of v4 COMPOUNDS later.
> (I was wrong about this BTW: being able to flush out all the dirty
> pages in a file to disk using a single COMPOUND would indeed be worth
> the trouble once we've managed to drop UDP as the primary NFS
> transport mechanism. For one thing, you would only tie up a single
> nfsd thread when writing to the file)


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
