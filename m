From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 25 Oct 2002 18:52:34 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021025.185234.08315285.taka@valinux.co.jp>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1851GG-0004Nh-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 03:00:12 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
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

> I have been thinking some more about this, trying to understand the
> big picture, and I'm afraid that I think I want some more changes.
> 
> In particular, I think it would be good to use 'struct xdr_buf' from
> sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
> we could share some of the infrastructure.

I just realized it would be hard to use the xdr_buf as it couldn't
handle data in a socket buffer. Each socket burfer consists of
some non-page data and some pages and each of them might have its
own offset and length.

> I'm not certain about receiving write requests.
> I imagine that it might work to:
>   1/ call xdr_partial_copy_from_skb to just copy the first 1K from the
>     skb into the head iovec, and hold onto the skbuf (like we
>     currently do).

And I came up with another idea that kNFSd could handles TCP data
in a socket buffer directly without copy if we can enhancemence the
tcp_read_sock() not to release it while kNFSd is using it.
kNFSd would handle TCP data as if it were a UDP datagram.
The differences are kNFSd may grab some TCP socket buffers at once
and the buffers may be shared to other kNFSd's.

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
