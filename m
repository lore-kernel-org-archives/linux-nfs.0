From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 30 Oct 2002 01:27:31 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021030.012731.104039610.taka@valinux.co.jp>
References: <15805.26221.530836.279218@charged.uio.no>
	<20021029.153629.55720711.taka@valinux.co.jp>
	<15806.42148.47823.817360@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186ZL6-0005ry-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 08:35:37 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <15806.42148.47823.817360@charged.uio.no>
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

Thank you for your reply.

>      > Shall we use ZERO_PAGE to pad RPC requests for the purpose of
>      > its performance?  Using non-page data is a little inefficient
>      > as the implementation of skbuff doesn't allow to append
>      > non-page data to a skbuff which already have pages. Only pages
>      > can be appneded to it.  If we didn't, TCP/IP stack would
>      > allocate a new page to store the small zero-padded data.
> 
> Hmmm... What if we just drop actually storing a pointer to the
> ZERO_PAGE? Instead, define the convention that
>
> if (xdr_buf->tail[0].iov_base == NULL)
> 	padding = xdr_buf->tail[0].iov_len;
> 
> and just have xprt_sendmsg() magically append 'padding' bytes from
> your ZERO_PAGE.

Yes, it's possible.
OK, I'll modify it.

> Unless, of course, you've got another use for the head_page/tail_page?

I just wanted to make it general.
I guessed head_page (or head_pages) might be usefull for big NFSv4
COMPOUND messages as we could send a head without any copies.
But it's just my guess.

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
