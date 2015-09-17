Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbbIQNZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 09:25:53 -0400
Date: Thu, 17 Sep 2015 09:25:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix v4.2 SEEK on files over 2 gigs
Message-ID: <20150917132552.GD9870@fieldses.org>
References: <20150916212127.GA5169@fieldses.org>
 <55FABA40.6010406@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55FABA40.6010406@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 17, 2015 at 09:04:00AM -0400, Anna Schumaker wrote:
> Hey Bruce,
> 
> I actually worked on a version of this patch on my own yesterday, too.  Looks like you beat me to submitting it!  :)

Oh, OK, well feel free to credit it however you'd like.

> On 09/16/2015 05:21 PM, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > We're incorrectly assigning a loff_t return to an int.  If SEEK_HOLE or
> > SEEK_DATA returns an offset over 2^31 then the application will see a
> > weird lseek() result (usually -EIO).
> 
> I saw roughly the same thing with xfstests generic/285.

I maybe should have included my reproducer in the changelog, which was:

	git clone git://git.infradead.org/users/dedekind/bmap-tools.git
	cd bmap-tools

	mount overs=4.2 localhost:/exports /mnt/
	dd if=/dev/zero of=/mnt/test1.image seek=2097152 bs=1K count=1

	./bmaptool  create  /mnt/test1.image

In the good case it outputs some xml, in the bad case it aborts with an
IO error.

--b.

> > Cc: stable@vger.kernel.org
> > Fixes: bdcc2cd14e4e "NFSv4.2: handle NFS-specific llseek errors"
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Reviewed-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> > ---
> >  fs/nfs/nfs42proc.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> > index d731bbf974aa..0f020e4d8421 100644
> > --- a/fs/nfs/nfs42proc.c
> > +++ b/fs/nfs/nfs42proc.c
> > @@ -175,10 +175,12 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
> >  {
> >  	struct nfs_server *server = NFS_SERVER(file_inode(filep));
> >  	struct nfs4_exception exception = { };
> > -	int err;
> > +	loff_t err;
> >  
> >  	do {
> >  		err = _nfs42_proc_llseek(filep, offset, whence);
> > +		if (err >= 0)
> > +			break;
> >  		if (err == -ENOTSUPP)
> >  			return -EOPNOTSUPP;
> >  		err = nfs4_handle_exception(server, err, &exception);
> > 
