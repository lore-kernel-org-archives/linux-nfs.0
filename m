Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39930 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933123Ab2C2Uug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 16:50:36 -0400
Date: Thu, 29 Mar 2012 16:50:35 -0400
From: Dr James Bruce Fields <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Orion Poplawski <orion@cora.nwra.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
Message-ID: <20120329205035.GB21493@fieldses.org>
References: <loom.20120329T182500-467@post.gmane.org>
 <1333040091.5547.32.camel@lade.trondhjem.org>
 <4F749CCA.3000400@cora.nwra.com>
 <1333042863.5547.37.camel@lade.trondhjem.org>
 <4F74A4D5.1040802@cora.nwra.com>
 <20120329193100.GA20329@fieldses.org>
 <1333052170.10318.6.camel@lade.trondhjem.org>
 <1333053750.10318.15.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1333053750.10318.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2012 at 08:42:24PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-03-29 at 16:16 -0400, Trond Myklebust wrote:
> > On Thu, 2012-03-29 at 15:31 -0400, Dr James Bruce Fields wrote:
> > > On Thu, Mar 29, 2012 at 12:07:17PM -0600, Orion Poplawski wrote:
> > > > On 03/29/2012 11:40 AM, Myklebust, Trond wrote:
> > > > >>Going back to v4 on EL5.8 server: nfsv4el.log, nfsv4f18.log
> > > > >>
> > > > >>Both get NFS4ERR_EXIST in this case.
> > > > >
> > > > >Which is an obvious server bug: it should be sending NFS4ERR_SYMLINK in
> > > > >reply to that OPEN.
> > > > >
> > > > >Bruce?
> > > > >
> > > > 
> > > > I can reproduce with a 3.4.0-0.rc0.git1.2.fc18 server as well.
> > > 
> > > Hm.  So how about this?  (Untested.)
> > > 
> > > Probably there should be a pynfs test too.
> > > 
> > > I'm assuming it should still be ERR_EXIST in the exclusive,
> > > exclusive4_1, and guarded cases.
> > > 
> > > --b.
> > > 
> > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > index 7423d71..2bfcad4 100644
> > > --- a/fs/nfsd/vfs.c
> > > +++ b/fs/nfsd/vfs.c
> > > @@ -1457,9 +1457,12 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > >  
> > >  		switch (createmode) {
> > >  		case NFS3_CREATE_UNCHECKED:
> > > -			if (! S_ISREG(dchild->d_inode->i_mode))
> > > -				err = nfserr_exist;
> > > -			else if (truncp) {
> > > +			if (! S_ISREG(dchild->d_inode->i_mode)) {
> > > +				if (rqstp->rq_vers == 4)
> > > +					err = nfserr_symlink;
> > > +				else
> > > +					err = nfserr_exist;
> > 
> > No. This should _never_ return NFS4ERR_EXIST.
> > 
> > It should return
> >       * NFS4ERR_ISDIR if the object is a directory
> >       * NFS4ERR_SYMLINK if it is symbolic link,
> >       * either NFS4ERR_WRONG_TYPE (NFSv4.1) or NFS4ERR_SYMLINK (NFSv4.0)
> >         if the object is any other non-regular file.
> 
> Basically, if an object already exists with that name, then
> NFS3_CREATE_UNCHECKED should be treated as if it is an ordinary OPEN (in
> the case of NFSv4) or LOOKUP (in the case of NFSv3).

Oh, so in the v3 case this should be nfs_ok, and it's up to the client
to check attributes on the result and decide what to do?

(Is this written down someplace?)

--b.
