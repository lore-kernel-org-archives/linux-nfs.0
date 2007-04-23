From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Missing handling for
	NFS4ERR_OLD_STATEID	in	nfs4_handle_exception?
Date: Mon, 23 Apr 2007 10:14:30 -0700
Message-ID: <1177348470.3531.25.camel@dyn9047022153>
References: <1175616589.3531.8.camel@dyn9047022153>
	<1176401268.6664.36.camel@heimdal.trondhjem.org>
	<20070418135754.GA15075@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg23E-0001Ux-7n
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 10:10:36 -0700
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hg23D-0005HT-45
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 10:10:10 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3NH9vR3006828
	for <nfs@lists.sourceforge.net>; Mon, 23 Apr 2007 13:09:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3NH9vxt475772
	for <nfs@lists.sourceforge.net>; Mon, 23 Apr 2007 13:09:57 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3NH9vCY017219
	for <nfs@lists.sourceforge.net>; Mon, 23 Apr 2007 13:09:57 -0400
In-Reply-To: <20070418135754.GA15075@dantu.rdu.redhat.com>
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

On Wed, 2007-04-18 at 09:57 -0400, Jeff Layton wrote:
> In that case, then what would you think about this patch, based on Frank's
> suggestion. The other option might be to set "ret = -EIO" to make it avoid
> the printk, but if all callers are expected to retry in that situation, I
> don't guess it matters much:

I think this is what we want, returning -EIO doesn't make sense to me
(realizing that all callers ignore the return code if exception->retry
is 1).

Frank

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f52cf5c..b456783 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2774,6 +2774,7 @@ int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct
>  				break;
>  		case -NFS4ERR_OLD_STATEID:
>  			exception->retry = 1;
> +			ret = 0;
>  	}
>  	/* We failed to handle the error */
>  	return nfs4_map_errors(ret);


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
