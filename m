From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Missing handling for NFS4ERR_OLD_STATEID
	in	nfs4_handle_exception?
Date: Tue, 24 Apr 2007 08:28:22 -0400
Message-ID: <20070424122820.GB27944@salusa.poochiereds.net>
References: <1175616589.3531.8.camel@dyn9047022153>
	<1176401268.6664.36.camel@heimdal.trondhjem.org>
	<20070418135754.GA15075@dantu.rdu.redhat.com>
	<1177348470.3531.25.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgK9d-0008PF-TO
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 05:29:58 -0700
Received: from ms-smtp-04.southeast.rr.com ([24.25.9.103])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgK9g-0002hV-5K
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 05:30:00 -0700
In-Reply-To: <1177348470.3531.25.camel@dyn9047022153>
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

On Mon, Apr 23, 2007 at 10:14:30AM -0700, Frank Filz wrote:
> On Wed, 2007-04-18 at 09:57 -0400, Jeff Layton wrote:
> > In that case, then what would you think about this patch, based on Frank's
> > suggestion. The other option might be to set "ret = -EIO" to make it avoid
> > the printk, but if all callers are expected to retry in that situation, I
> > don't guess it matters much:
> 
> I think this is what we want, returning -EIO doesn't make sense to me
> (realizing that all callers ignore the return code if exception->retry
> is 1).
> 
> Frank
> 

True, though you can make the case that returning with an error code of 0
implies "success" and that doesn't make much sense here either. Regardless,
since all current callers seem to retry indefinitely in this situation, then
it really doesn't make much difference either way.

-- Jeff

> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index f52cf5c..b456783 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2774,6 +2774,7 @@ int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct
> >  				break;
> >  		case -NFS4ERR_OLD_STATEID:
> >  			exception->retry = 1;
> > +			ret = 0;
> >  	}
> >  	/* We failed to handle the error */
> >  	return nfs4_map_errors(ret);
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
