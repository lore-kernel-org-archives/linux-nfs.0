From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 9/9] SUNRPC: skb_read_bits is the same
	as	xs_tcp_copy_data
Date: Thu, 12 Oct 2006 16:08:57 -0700
Message-ID: <1160694537.12029.7.camel@lade.trondhjem.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211523.8734.63869.stgit@ingres.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GY9fu-0000yw-TQ
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 16:09:14 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GY9fu-0006FD-Gy
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 16:09:15 -0700
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

On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> Clean-up: eliminate xs_tcp_copy_data -- it's exactly the same logic as the
> common routine skb_read_bits.  The UDP and TCP socket read code now share
> the same routine for copying data into an xdr_buf.
> 
> Test plan:
> None.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/xdr.h |    1 +
>  net/sunrpc/socklib.c       |    5 +++--
>  net/sunrpc/xprtsock.c      |   24 ++++--------------------
>  3 files changed, 8 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index 953723b..73b700e 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -155,6 +155,7 @@ typedef struct {
>  
>  typedef size_t (*skb_read_actor_t)(skb_reader_t *desc, void *to, size_t len);
>  
> +size_t skb_read_bits(skb_reader_t *desc, void *to, size_t len);
>  extern int csum_partial_copy_to_xdr(struct xdr_buf *, struct sk_buff *);
>  extern ssize_t xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
>  		skb_reader_t *, skb_read_actor_t);
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
> +EXPORT_SYMBOL_GPL(skb_read_bits);
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Why do you need this?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
