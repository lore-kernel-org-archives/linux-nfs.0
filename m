From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Tue, 29 Oct 2002 16:09:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15806.42148.47823.817360@charged.uio.no>
References: <20021024.103349.26272209.taka@valinux.co.jp>
	<20021027.193917.78705070.taka@valinux.co.jp>
	<15805.26221.530836.279218@charged.uio.no>
	<20021029.153629.55720711.taka@valinux.co.jp>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Y00-0004xp-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 07:09:44 -0800
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021029.153629.55720711.taka@valinux.co.jp>
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

     > Shall we use ZERO_PAGE to pad RPC requests for the purpose of
     > its performance?  Using non-page data is a little inefficient
     > as the implementation of skbuff doesn't allow to append
     > non-page data to a skbuff which already have pages. Only pages
     > can be appneded to it.  If we didn't, TCP/IP stack would
     > allocate a new page to store the small zero-padded data.

Hmmm... What if we just drop actually storing a pointer to the
ZERO_PAGE? Instead, define the convention that

if (xdr_buf->tail[0].iov_base == NULL)
	padding = xdr_buf->tail[0].iov_len;

and just have xprt_sendmsg() magically append 'padding' bytes from
your ZERO_PAGE.

Unless, of course, you've got another use for the head_page/tail_page?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
