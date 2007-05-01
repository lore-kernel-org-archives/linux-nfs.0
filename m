From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: supress warnings about
	NFS4ERR_OLD_STATEID	in nfs4_handle_exception
Date: Tue, 1 May 2007 10:58:36 -0400
Message-ID: <20070501145835.GB24354@dantu.rdu.redhat.com>
References: <20070426191336.GB31081@dantu.rdu.redhat.com>
	<1178030549.5444.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: ffilz@us.ibm.com, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HitoY-0004iK-BC
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 07:58:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HitoZ-0005qk-KG
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 07:58:53 -0700
In-Reply-To: <1178030549.5444.11.camel@heimdal.trondhjem.org>
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

On Tue, May 01, 2007 at 07:42:29AM -0700, Trond Myklebust wrote:
> On Thu, 2007-04-26 at 15:13 -0400, Jeff Layton wrote:
> > I recently posted this patch to the nfs mailing list, but got no comment.
> > Reposting with an actual "[PATCH]" subject...
> > 
> > In certain situations, a NFSv4 client can end up with a set of racing calls
> > that cause the server to return a NFS4ERR_OLD_STATEID error. When this occurs,
> > the only real recourse that the client has is to retry the call. In the
> > current code, when this occurs, it triggers a useless printk (in
> > nfs4_map_errors):
> > 
> >     nfs4_map_errors could not handle NFSv4 error 10024
> > 
> > Trond recently mentioned that we really don't need to worry users with that
> > info. The following patch is based on a suggestion by Frank Filz and supresses
> > this error. Changing the return code here to 0 should be safe since all callers
> > of nfs4_handle_exception are expected to retry the call in this situation
> > anyway.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > Signed-off-by: Frank Filz <ffilz@us.ibm.com>
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
> Surely "return 0;" is more efficient.
> 
> ...and a minor nit about the comment: it doesn't trigger a printk(). It
> rather triggers a dprintk(), (which should be turned off by default
> unless you happen to be debugging the code).
> 
> The other nit is that I'm not sure the dprintk() is totally useless. It
> is always nice to know _why_ the thing looped when you are debugging.
> That said, we should perhaps rather put the dprintk() for that in
> nfs4_handle_exception instead...
> 
> Trond
> 
> 

Argh. My mistake, that's what I get for looking at old code and new code at
the same time. Since this is a dprintk, I agree that we should probably
just toss this patch. If you're debugging, then there's good reason to want to
see this.

As for moving the dprintk, I'm not so sure that's a great idea either.
nfs4_map_error is called from a couple of different places and I'd think
leaving the dprintk the a more "general" location would be good.

-- Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
