From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 6/15] knfsd: nfs3svc_decode_writeargs assumes data	follows
	header
Date: Fri, 18 May 2007 14:35:18 -0400
Message-ID: <20070518183518.GB4843@fieldses.org>
References: <1179510324.23385.119.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7IR-0006dd-M6
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:35:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp7IP-000753-BX
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:35:21 -0700
In-Reply-To: <1179510324.23385.119.camel@trinity.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, May 18, 2007 at 12:45:24PM -0500, Tom Tucker wrote:
> 
> The nfs3svc_decode_writeargs routine assumes that the data for an 
> NFS write comes inline with the header when it verifies the message. 
> Since the data for the write does not appear immediately following the 
> header when RDMA is the transport, this check had to be modified.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  fs/nfsd/nfs3xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 7e4bb0a..0f08c4b 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -400,7 +400,7 @@ nfs3svc_decode_writeargs(struct svc_rqst
>  	rqstp->rq_vec[v].iov_len = len;
>  	args->vlen = v+1;
>  
> -	return args->count == args->len && rqstp->rq_vec[0].iov_len > 0;
> +	return args->count == args->len && rqstp->rq_arg.len > hdr;
>  }

You'll want to rebase against at least v2.6.22-rc1; see f34b9568.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
