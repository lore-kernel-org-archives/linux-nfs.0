Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47408 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993140AbbEEOSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 10:18:02 -0400
Date: Tue, 5 May 2015 10:18:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150505141801.GB27106@fieldses.org>
References: <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150504220130.GB16827@fieldses.org>
 <5548CBA3.9080608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5548CBA3.9080608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 09:54:43PM +0800, Kinglong Mee wrote:
> On 5/5/2015 6:01 AM, J. Bruce Fields wrote:
> > + * Unlike lookup_one_len, it should be called without the parent
> > + * i_mutex held, and will take the i_mutex itself if necessary.
> > + */
> > +struct dentry *lookup_one_len_unlocked(const char *name,
> > +				       struct dentry *base, int len)
> > +{
> > +	struct qstr this;
> > +	unsigned int c;
> > +	int err;
> > +	struct dentry *ret;
> > +
> > +	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
> 
> Remove this line.

Whoops, thanks.

> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index a30e79900086..cc7995762190 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >  		host_err = PTR_ERR(dentry);
> >  		if (IS_ERR(dentry))
> >  			goto out_nfserr;
> > +		if (!S_ISREG(d_inode(dentry)->i_mode)) {
> 
> Got a crash here tested by pynfs,

OK, I guess I just forgot to take into account negative dentries.
Testing that now with (!(d_inode(dentry) && S_ISREG(..))).

--b.

> # ./testserver.py 127.0.0.1:/nfs/pnfs/ --rundeps --maketree open
> 
> PID: 2314   TASK: ffff88006ad2cfc0  CPU: 0   COMMAND: "nfsd"
>  #0 [ffff88006adc7870] machine_kexec at ffffffff8104debb
>  #1 [ffff88006adc78e0] crash_kexec at ffffffff810f92a2
>  #2 [ffff88006adc79b0] oops_end at ffffffff81015c28
>  #3 [ffff88006adc79e0] no_context at ffffffff8105a9af
>  #4 [ffff88006adc7a50] __bad_area_nosemaphore at ffffffff8105ac90
>  #5 [ffff88006adc7aa0] bad_area_nosemaphore at ffffffff8105ae23
>  #6 [ffff88006adc7ab0] __do_page_fault at ffffffff8105b13e
>  #7 [ffff88006adc7b10] do_page_fault at ffffffff8105b4df
>  #8 [ffff88006adc7b50] page_fault at ffffffff81713258
>     [exception RIP: nfsd_lookup_dentry+231]
>     RIP: ffffffffa0447b87  RSP: ffff88006adc7c08  RFLAGS: 00010283
>     RAX: ffff88006a9d2180  RBX: ffff88006ad80068  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: ffff88007fdf4eb0  RDI: ffff88006a9d2180
>     RBP: ffff88006adc7c88   R8: ffff88006b13dcc0   R9: 0000000000000000
>     R10: ffff88006adb6cc0  R11: ffff88006adb6cc0  R12: ffff88006a9d0cc0
>     R13: ffff88006adc7ca0  R14: ffff88006adc7ca8  R15: ffff88006ad640bc
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>  #9 [ffff88006adc7c90] nfsd_lookup at ffffffffa0448029 [nfsd]
> #10 [ffff88006adc7cf0] nfsd4_open at ffffffffa0456cbb [nfsd]
> #11 [ffff88006adc7d60] nfsd4_proc_compound at ffffffffa0457317 [nfsd]
> #12 [ffff88006adc7dc0] nfsd_dispatch at ffffffffa0442f83 [nfsd]
> #13 [ffff88006adc7e00] svc_process_common at ffffffffa0160c5b [sunrpc]
> #14 [ffff88006adc7e70] svc_process at ffffffffa0161cc3 [sunrpc]
> #15 [ffff88006adc7ea0] nfsd at ffffffffa044294f [nfsd]
> #16 [ffff88006adc7ed0] kthread at ffffffff810a9d07
> #17 [ffff88006adc7f50] ret_from_fork at ffffffff81711b62
> 
> thanks,
> Kinglong Mee
