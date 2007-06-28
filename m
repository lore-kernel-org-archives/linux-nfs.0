From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Re: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 19:53:27 -0700
Message-ID: <20070628025327.GA18337@ligo.caltech.edu>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3k8X-0003br-5h
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:53:37 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3k8Y-0003en-98
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:53:40 -0700
In-Reply-To: <20070627211559.e9fc68dd.jlayton@redhat.com>
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

On Wed, Jun 27, 2007 at 09:15:59PM -0400, Jeff Layton wrote:
> On Wed, 27 Jun 2007 17:59:57 -0700
> Stuart Anderson <anderson@ligo.caltech.edu> wrote:
> 
> > More precisely, applying this patch to the 2.6.20.14 kernel plus the
> > revalidate-the-fsid patch did not result in any changes. Does the
> > O_EXCL patch require some other supporting patches relative to 2.6.20.14?
> > 
> > or perhaps it is necessary to rebase to a newer kernel before applying it?
> > even tough it applies, builds and runs with 2.6.20.14?
> > 
> > Thanks.
> > 
> 
> With Linux, both client and server side were broken in this respect.
> The server didn't set the bitmask in the reply and the client didn't
> look at it anyway. It's possible that Solaris server is broken in this
> regard as well. It would be interesting to see a capture here,
> particularly one containing the reply from the CREATE.

Possible, but when we switch the client from Linux to Solaris and share
the same filesytem from the same server there are no O_EXCL problems.

I will see if we can capture the bits. Any recomendations on which tool
with what options would be most useful to capture the useful traffic?

> 
> Exactly what version of Solaris is the server running?

# cat /etc/release 
                        Solaris 10 11/06 s10x_u3wos_10 X86
           Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
                        Use is subject to license terms.
                           Assembled 14 November 2006
# uname -v
Generic_118855-36


Somewhat related is the reason that we are tring NFSV4 on Linux clients is
that with NFSV3 ACL's do not work between Linux and Solaris if the filesystem
on the Solaris server is ZFS, e.g., cp -p will generate interesting error
messages. While I would rather stay with NFSV4 if possible, has anyone
gotten this configuration to work with V3?

> 
> > 
> > On Wed, Jun 27, 2007 at 05:49:04PM -0700, Stuart Anderson wrote:
> > > Unfortunately this patch did not have any observable affects.
> > > 
> > > On Wed, Jun 27, 2007 at 07:43:25PM -0400, Trond Myklebust wrote:
> > > > On Wed, 2007-06-27 at 16:31 -0700, Stuart Anderson wrote:
> > > > > The following simple program creates files with un-initialized mtime values
> > > > > on a Linux NFSv4 client mounting from a Solaris NFSv4 server--at least the
> > > > > mtimes are wildly different each time the program is run. The problem is
> > > > > reproducible but does not happen under any of the following circumstances:
> > > > > 
> > > > > 1) Drop O_EXCL from open() call.
> > > > > 2) NFS mount using v3.
> > > > > 3) Switch NFS v4 client from Linux to Solaris.
> > > > > 
> > > > > This is on an FC4 machine with the 2.6.20.14 kernel plus Trond's recent
> > > > > revalidate-the-fsid-on-the-current-dir-not-the-root-dir patch
> > > > > and nfs-utils 1.0.9-16 backported from CentOS 5.
> > > > > 
> > > > > Thanks.
> > > > 
> > > > Doesn't Jeff's patch fix it?
> > > > 
> > > > Trond
> > > > 
> > > > 
> > > 
> > > > From: Jeff Layton <jlayton@redhat.com>
> > > > Date: Tue, 5 Jun 2007 14:49:03 -0400
> > > > NFS4: on a O_EXCL OPEN make sure SETATTR sets the fields holding the
> > > > 	verifier
> > > > Subject: No Subject
> > > > 
> > > > The Linux NFS4 client simply skips over the bitmask in an O_EXCL open
> > > > call and so it doesn't bother to reset any fields that may be holding
> > > > the verifier. This patch has us save the first two words of the bitmask
> > > > (which is all the current client has #defines for). The client then
> > > > later checks this bitmask and turns on the appropriate flags in the
> > > > sattr->ia_verify field for the following SETATTR call.
> > > > 
> > > > This patch only currently checks to see if the server used the atime
> > > > and mtime slots for the verifier (which is what the Linux server uses
> > > > for this). I'm not sure of what other fields the server could
> > > > reasonably use, but adding checks for others should be trivial.
> > > > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > ---
> > > > 
> > > >  fs/nfs/nfs4proc.c       |   20 ++++++++++++++++++++
> > > >  fs/nfs/nfs4xdr.c        |    9 +++++++--
> > > >  include/linux/nfs4.h    |    1 +
> > > >  include/linux/nfs_xdr.h |    1 +
> > > >  4 files changed, 29 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > > > index 3cc7544..fee2d14 100644
> > > > --- a/fs/nfs/nfs4proc.c
> > > > +++ b/fs/nfs/nfs4proc.c
> > > > @@ -943,6 +943,22 @@ static struct nfs4_state *nfs4_open_delegated(struct inode *inode, int flags, st
> > > >  }
> > > >  
> > > >  /*
> > > > + * on an EXCLUSIVE create, the server should send back a bitmask with FATTR4-*
> > > > + * fields corresponding to attributes that were used to store the verifier.
> > > > + * Make sure we clobber those fields in the later setattr call
> > > > + */
> > > > +static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct iattr *sattr)
> > > > +{
> > > > +	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
> > > > +	    !(sattr->ia_valid & ATTR_ATIME_SET))
> > > > +		sattr->ia_valid |= ATTR_ATIME;
> > > > +
> > > > +	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
> > > > +	    !(sattr->ia_valid & ATTR_MTIME_SET))
> > > > +		sattr->ia_valid |= ATTR_MTIME;
> > > > +}
> > > > +
> > > > +/*
> > > >   * Returns a referenced nfs4_state
> > > >   */
> > > >  static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct iattr *sattr, struct rpc_cred *cred, struct nfs4_state **res)
> > > > @@ -973,6 +989,9 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct
> > > >  	if (status != 0)
> > > >  		goto err_opendata_free;
> > > >  
> > > > +	if (opendata->o_arg.open_flags & O_EXCL)
> > > > +		nfs4_exclusive_attrset(opendata, sattr);
> > > > +
> > > >  	status = -ENOMEM;
> > > >  	state = nfs4_opendata_to_nfs4_state(opendata);
> > > >  	if (state == NULL)
> > > > @@ -1784,6 +1803,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
> > > >  		status = nfs4_do_setattr(state->inode, &fattr, sattr, state);
> > > >  		if (status == 0)
> > > >  			nfs_setattr_update_inode(state->inode, sattr);
> > > > +		nfs_post_op_update_inode(state->inode, &fattr);
> > > >  	}
> > > >  	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
> > > >  		status = nfs4_intent_set_file(nd, &path, state);
> > > > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > > > index 8003c91..5efd314 100644
> > > > --- a/fs/nfs/nfs4xdr.c
> > > > +++ b/fs/nfs/nfs4xdr.c
> > > > @@ -3269,7 +3269,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
> > > >  static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
> > > >  {
> > > >          __be32 *p;
> > > > -        uint32_t bmlen;
> > > > +        uint32_t savewords, bmlen, i;
> > > >          int status;
> > > >  
> > > >          status = decode_op_hdr(xdr, OP_OPEN);
> > > > @@ -3287,7 +3287,12 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
> > > >                  goto xdr_error;
> > > >  
> > > >          READ_BUF(bmlen << 2);
> > > > -        p += bmlen;
> > > > +	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
> > > > +	for (i = 0; i < savewords; ++i)
> > > > +		READ32(res->attrset[i]);
> > > > +
> > > > +	p += (bmlen - savewords);
> > > > +
> > > >  	return decode_delegation(xdr, res);
> > > >  xdr_error:
> > > >  	dprintk("%s: Bitmap too large! Length = %u\n", __FUNCTION__, bmlen);
> > > > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > > > index 7e7f33a..8726491 100644
> > > > --- a/include/linux/nfs4.h
> > > > +++ b/include/linux/nfs4.h
> > > > @@ -15,6 +15,7 @@
> > > >  
> > > >  #include <linux/types.h>
> > > >  
> > > > +#define NFS4_BITMAP_SIZE	2
> > > >  #define NFS4_VERIFIER_SIZE	8
> > > >  #define NFS4_STATEID_SIZE	16
> > > >  #define NFS4_FHSIZE		128
> > > > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > > > index 10c26ed..f7100df 100644
> > > > --- a/include/linux/nfs_xdr.h
> > > > +++ b/include/linux/nfs_xdr.h
> > > > @@ -144,6 +144,7 @@ struct nfs_openres {
> > > >  	nfs4_stateid		delegation;
> > > >  	__u32			do_recall;
> > > >  	__u64			maxsize;
> > > > +	__u32			attrset[NFS4_BITMAP_SIZE];
> > > >  };
> > > >  
> > > >  /*
> > > 
> > > 
> > > -- 
> > > Stuart Anderson  anderson@ligo.caltech.edu
> > > http://www.ligo.caltech.edu/~anderson
> > 
> > -- 
> > Stuart Anderson  anderson@ligo.caltech.edu
> > http://www.ligo.caltech.edu/~anderson
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
