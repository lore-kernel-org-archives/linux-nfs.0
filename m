Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49234 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbbEHOKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 10:10:35 -0400
Date: Fri, 8 May 2015 10:10:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150508141034.GC23753@fieldses.org>
References: <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150504220130.GB16827@fieldses.org>
 <5548CBA3.9080608@gmail.com>
 <20150505141801.GB27106@fieldses.org>
 <20150505155203.GD27106@fieldses.org>
 <20150507153116.GI27106@fieldses.org>
 <20150508084230.716439d5@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150508084230.716439d5@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2015 at 08:42:30AM +1000, NeilBrown wrote:
> On Thu, 7 May 2015 11:31:16 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, May 05, 2015 at 11:52:03AM -0400, J. Bruce Fields wrote:
> > > On Tue, May 05, 2015 at 10:18:01AM -0400, J. Bruce Fields wrote:
> > > > On Tue, May 05, 2015 at 09:54:43PM +0800, Kinglong Mee wrote:
> > > > > On 5/5/2015 6:01 AM, J. Bruce Fields wrote:
> > > > > > + * Unlike lookup_one_len, it should be called without the parent
> > > > > > + * i_mutex held, and will take the i_mutex itself if necessary.
> > > > > > + */
> > > > > > +struct dentry *lookup_one_len_unlocked(const char *name,
> > > > > > +				       struct dentry *base, int len)
> > > > > > +{
> > > > > > +	struct qstr this;
> > > > > > +	unsigned int c;
> > > > > > +	int err;
> > > > > > +	struct dentry *ret;
> > > > > > +
> > > > > > +	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
> > > > > 
> > > > > Remove this line.
> > > > 
> > > > Whoops, thanks.
> > > > 
> > > > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > > > index a30e79900086..cc7995762190 100644
> > > > > > --- a/fs/nfsd/vfs.c
> > > > > > +++ b/fs/nfsd/vfs.c
> > > > > > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > > > > >  		host_err = PTR_ERR(dentry);
> > > > > >  		if (IS_ERR(dentry))
> > > > > >  			goto out_nfserr;
> > > > > > +		if (!S_ISREG(d_inode(dentry)->i_mode)) {
> > > > > 
> > > > > Got a crash here tested by pynfs,
> > > > 
> > > > OK, I guess I just forgot to take into account negative dentries.
> > > > Testing that now with (!(d_inode(dentry) && S_ISREG(..))).
> > > 
> > > And I also forgot nfs3xdr.c.
> > 
> > But, this doesn't look good.
> > 
> > OK, to be fair I'm not sure whether this was already happening before this
> > patch.
> 
> None of the stacks show any code that we changed, so I'm guessing it is a
> separate issues as you hint at.
> 
> If I didn't have a list as long as my arm of things I really should be doing,
> I'd go diving into the XFS code ....

Yeah.  Looks like it might be intermittent.  I'll keep an eye on it and
report to xfs people, I guess....

--b.
