From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Missing handling for NFS4ERR_OLD_STATEID
	in	nfs4_handle_exception?
Date: Wed, 18 Apr 2007 09:57:54 -0400
Message-ID: <20070418135754.GA15075@dantu.rdu.redhat.com>
References: <1175616589.3531.8.camel@dyn9047022153>
	<1176401268.6664.36.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilzlnx@us.ibm.com>,
	NFS List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeAfp-0000FL-NA
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 06:58:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeAfs-00065G-2J
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 06:58:20 -0700
In-Reply-To: <1176401268.6664.36.camel@heimdal.trondhjem.org>
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

On Thu, Apr 12, 2007 at 02:07:48PM -0400, Trond Myklebust wrote:
> On Tue, 2007-04-03 at 09:09 -0700, Frank Filz wrote:
> > I'm looking at the following code, and wondering if something is missing
> > in the handling of NFS4ERR_OLD_STATEID. The result is that if this error
> > occurs, nfs4_map_errors() will print:
> > 
> > 	nfs4_map_errors could not handle NFSv4 error 10024
> 
> Agreed. We don't really need to worry users with that printk.
> 
> > It also looks like the handling of NFS4ERR_DELAY etc. may be wrong,
> > since if nfs4_delay() returns without error, it falls through to the
> > handling of NFS4ERR_OLD_STATEID.
> 
> The correct way to deal with both NFS4ERR_DELAY and NFS4ERR_OLD_STATEID
> is simply to retry the request.
> 
> As I said in an earlier mail, the NFS4ERR_OLD_STATEID is occurring
> because some OPEN/OPEN_DOWNGRADE has caused the stateid to change. All
> we can do is retry with the new stateid.
> 
> Cheers,
>   Trond
> 

In that case, then what would you think about this patch, based on Frank's
suggestion. The other option might be to set "ret = -EIO" to make it avoid
the printk, but if all callers are expected to retry in that situation, I
don't guess it matters much:

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f52cf5c..b456783 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2774,6 +2774,7 @@ int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct
 				break;
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
+			ret = 0;
 	}
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
