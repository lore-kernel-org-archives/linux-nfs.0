From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: NFS_All on alpha
Date: 04 Sep 2002 11:47:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1031154426.2779.19.camel@twitch>
References: <1031086991.5196.53.camel@twitch>
	<shs3csqr869.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mcNA-0005eU-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 08:47:16 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs3csqr869.fsf@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Thank you.  That seems to have taken care of it.

David

On Tue, 2002-09-03 at 18:59, Trond Myklebust wrote:
> >>>>> " " == David B Ritch <dritch@hpti.com> writes:
> 
>      > Should xdr_shift_buf take an int or a long?  Are there any
> 
> It should indeed take a size_t as is done in 2.5.x, and
> 2.4.20-pre5. Sorry I forgot to apply that change to my own tree.
> 
>      > other known problems for a 64-bit architecture in the nfs_all
>      > patches?
> 
> Not that I'm aware of.
> 
> Cheers,
>   Trond
> 
> diff -Nru a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> --- a/include/linux/sunrpc/xdr.h	Wed Sep  4 00:58:53 2002
> +++ b/include/linux/sunrpc/xdr.h	Wed Sep  4 00:58:53 2002
> @@ -138,7 +138,7 @@
>   */
>  extern int xdr_kmap(struct iovec *, struct xdr_buf *, unsigned int);
>  extern void xdr_kunmap(struct xdr_buf *, unsigned int);
> -extern void xdr_shift_buf(struct xdr_buf *, unsigned int);
> +extern void xdr_shift_buf(struct xdr_buf *, size_t);
>  extern void xdr_zero_buf(struct xdr_buf *, unsigned int);
>  
>  /*
-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
