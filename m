Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39818 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980Ab2BAVq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 16:46:58 -0500
Date: Wed, 1 Feb 2012 16:46:56 -0500
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: cleanup setting of default max_block_size
Message-ID: <20120201214656.GA19075@fieldses.org>
References: <1327963365-2921-1-git-send-email-bfields@redhat.com>
 <4F273FD4.3020005@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F273FD4.3020005@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 31, 2012 at 09:11:48AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields 写道:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Move calculation of the default into a helper function.
> > 
> > Get rid of an unused variable "err" while we're there.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfssvc.c |   44 ++++++++++++++++++++++++--------------------
> >  1 files changed, 24 insertions(+), 20 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index eda7d7e..2ad5ffe 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -307,33 +307,37 @@ static void set_max_drc(void)
> >  	dprintk("%s nfsd_drc_max_mem %u ¥n", __func__, nfsd_drc_max_mem);
> >  }
> >  
> > -int nfsd_create_serv(void)
> > +static int nfsd_get_default_max_blksize(void)
> >  {
> > -	int err = 0;
> > +	struct sysinfo i;
> > +	unsigned long target;
> > +	unsigned long bytes;
> > +
> > +	si_meminfo(&i);
> > +	target = i.totalram << PAGE_SHIFT;
> > +	/*
> > +	 * Aim for 1/4096 of memory per thread This gives 1MB on 4Gig
> > +	 * machines, but only uses 32K on 128M machines.  Bottom out at
> > +	 * 8K on 32M and smaller.  Of course, this is only a default.
> > +	 */
> > +	target <<= 12;
> 
>   Should use target = i.totalram << (PAGE_SHIFT - 12);
> 
>   target = i.totalram << PAGE_SHIFT; and 
>   target <<= 12;
>   means target = i.totalram << (PAGE_SHIFT + 12);

Yes, thanks for catching that.

Also, splitting up the calculation as I did above risks overflow at the
first step.

I'll fix that....

--b.
