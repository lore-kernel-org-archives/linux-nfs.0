From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 9/9] SUNRPC: skb_read_bits is the same as
	xs_tcp_copy_data
Date: Fri, 13 Oct 2006 08:25:16 +0100
Message-ID: <20061013072516.GA13531@infradead.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211523.8734.63869.stgit@ingres.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GYHQ1-0000My-7q
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 00:25:21 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GYHQ0-0006DL-V0
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 00:25:22 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061012211523.8734.63869.stgit@ingres.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Oct 12, 2006 at 05:15:23PM -0400, Chuck Lever wrote:
> Clean-up: eliminate xs_tcp_copy_data -- it's exactly the same logic as the
> common routine skb_read_bits.  The UDP and TCP socket read code now share
> the same routine for copying data into an xdr_buf.

Looks good, but skb_read_bits is a pretty bad name for a public function
in sunrpc code.

> diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
> index 6f17527..9d20136 100644
> --- a/net/sunrpc/socklib.c
> +++ b/net/sunrpc/socklib.c
> @@ -24,16 +24,17 @@ #include <linux/sunrpc/xdr.h>
>   * Possibly called several times to iterate over an sk_buff and copy
>   * data out of it.
>   */
> -static size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len)
> +size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len)
>  {
>  	if (len > desc->count)
>  		len = desc->count;
> -	if (skb_copy_bits(desc->skb, desc->offset, to, len))
> +	if (unlikely(skb_copy_bits(desc->skb, desc->offset, to, len)))
>  		return 0;
>  	desc->count -= len;
>  	desc->offset += len;
>  	return len;
>  }

But given that this code doesn't contain any sunrpc specifics it could
aswell move to net/core/skbuff.c


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
