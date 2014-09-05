Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:34889 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010AbaIELkN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 07:40:13 -0400
Received: by mail-qc0-f178.google.com with SMTP id x13so11890036qcv.23
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 04:40:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 07:40:10 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/5] nfsd: add a v4_end_grace file to /proc/fs/nfsd
Message-ID: <20140905074010.0ebc7f3f@tlielax.poochiereds.net>
In-Reply-To: <20140904195420.GB14576@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<1408473509-14010-4-git-send-email-jlayton@primarydata.com>
	<20140904195420.GB14576@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 15:54:20 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Aug 19, 2014 at 02:38:27PM -0400, Jeff Layton wrote:
> > Allow a privileged userland process to end the v4 grace period early.
> > Any write to the file will cause the v4 grace period to be lifted.
> > The basic idea with this will be to allow the userland client tracking
> > program to lift the grace period once it knows that no more clients
> > will be reclaiming state.
> ...
> > +/**
> > + * write_v4_end_grace - release grace period for nfsd's v4.x lock manager
> > + *
> > + * Input:
> > + *			buf:		ignored
> > + *			size:		zero
> > + * OR
> > + *
> > + * Input:
> > + * 			buf:		any value
> > + *			size:		non-zero length of C string in @buf
> > + * Output:
> > + *			passed-in buffer filled with "Y" or "N" with a newline
> > + *			and NULL-terminated C string. This indicates whether
> > + *			the grace period has ended in the current net
> > + *			namespace. Return code is the size in bytes of the
> > + *			string. Writing to the file will end the grace period
> > + *			for nfsd's v4 lock manager.
> > + */
> > +static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
> > +{
> > +	struct net *net = file->f_dentry->d_sb->s_fs_info;
> > +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > +
> > +	if (size > 0)
> > +		nfsd4_end_grace(nn);
> 
> Ditto for this one.
> 

Sure. I'll fix that up in the next iteration.

> Do we really need separate files for nlm and nfsd?
> 
> I think the separate nlm and nfsd grace periods may just be a historical
> mistake.
> 

statd and nfsdcltrack are separate programs, and both will need to
"sign off" before we can lift the grace period. With the way that grace
period management works today, I don't see a way to do this without
separate files. If you have an idea in mind for how to unify this
interface then I'm happy to entertain it however...

-- 
Jeff Layton <jlayton@primarydata.com>
