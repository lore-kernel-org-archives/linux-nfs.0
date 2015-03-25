Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:34566 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbbCYPtf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 11:49:35 -0400
Received: by yhch68 with SMTP id h68so13678735yhc.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 08:49:34 -0700 (PDT)
Date: Wed, 25 Mar 2015 11:49:31 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chengyu Song <csong84@gatech.edu>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, taesoo@gatech.edu, changwoo@gatech.edu,
        sanidhya@gatech.edu, blee@gatech.edu
Subject: Re: [PATCH 1/1] nfsd: incorrect check for debugfs returns
Message-ID: <20150325114931.20f186e4@tlielax.poochiereds.net>
In-Reply-To: <20150325150856.GB13764@fieldses.org>
References: <1427165885-20823-1-git-send-email-csong84@gatech.edu>
	<20150324064420.515096c7@tlielax.poochiereds.net>
	<20150325150856.GB13764@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Mar 2015 11:08:56 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Mar 24, 2015 at 06:44:20AM -0400, Jeff Layton wrote:
> > On Mon, 23 Mar 2015 22:58:05 -0400
> > Chengyu Song <csong84@gatech.edu> wrote:
> > 
> > > debugfs_create_dir and debugfs_create_file may return -ENODEV when debugfs
> > > is not configured, so the return value should be checked against ERROR_VALUE
> > > as well, otherwise the later dereference of the dentry pointer would crash
> > > the kernel.
> > > 
> > > Signed-off-by: Chengyu Song <csong84@gatech.edu>
> > > ---
> > >  fs/nfsd/fault_inject.c | 12 ++++++++----
> > >  1 file changed, 8 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> > > index c16bf5a..621d065 100644
> > > --- a/fs/nfsd/fault_inject.c
> > > +++ b/fs/nfsd/fault_inject.c
> > > @@ -132,19 +132,23 @@ int nfsd_fault_inject_init(void)
> > >  	unsigned int i;
> > >  	struct nfsd_fault_inject_op *op;
> > >  	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> > > +	struct dentry *dent;
> > >  
> > > -	debug_dir = debugfs_create_dir("nfsd", NULL);
> > > -	if (!debug_dir)
> > > +	dent = debugfs_create_dir("nfsd", NULL);
> > > +	if (IS_ERR_OR_NULL(dent))
> > >  		goto fail;
> > > +	debug_dir = dent;
> > >  
> > >  	for (i = 0; i < NUM_INJECT_OPS; i++) {
> > >  		op = &inject_ops[i];
> > > -		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
> > > +		dent = debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);
> > > +		if (IS_ERR_OR_NULL(dent))
> > >  			goto fail;
> > > +
> > >  	}
> > >  	return 0;
> > >  
> > >  fail:
> > >  	nfsd_fault_inject_cleanup();
> > > -	return -ENOMEM;
> > > +	return dent ? PTR_ERR(dent) : -ENOMEM;
> > >  }
> > 
> > No objection to taking this patch in the near term if it helps, but we
> > had discussed over the summer just removing the NFS fault injection
> > framework.
> > 
> > Bruce, any objections to making that happen for v4.1?
> 
> I was prepared to, but I think Redhat QA people told me that they do use
> it--which means other people may too, so I'm sort of reluctant to tear
> it out even if it's imperfect.
> 
> --b.

Fair enough then. I'll leave it be...

-- 
Jeff Layton <jeff.layton@primarydata.com>
