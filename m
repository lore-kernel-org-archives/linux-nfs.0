Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47725 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbaBYKV2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Feb 2014 05:21:28 -0500
Date: Tue, 25 Feb 2014 11:21:26 +0100
From: Jan Kara <jack@suse.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jan Kara <jack@suse.cz>, Matthew Rahtz <mrahtz@rapitasystems.com>,
        linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: warning in ext4_journal_start_sb on filesystem freeze
Message-ID: <20140225102126.GB1669@quack.suse.cz>
References: <217983071.143460.1385453196946.JavaMail.zimbra@rapitasystems.com>
 <1697998867.143517.1385454051031.JavaMail.zimbra@rapitasystems.com>
 <20131126125826.GA4503@quack.suse.cz>
 <622177618.727.1393062606061.JavaMail.zimbra@rapitasystems.com>
 <20140224095525.GA20532@quack.suse.cz>
 <20140224154532.GB11992@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140224154532.GB11992@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 24-02-14 10:45:32, J. Bruce Fields wrote:
> On Mon, Feb 24, 2014 at 10:55:25AM +0100, Jan Kara wrote:
> > On Sat 22-02-14 09:50:06, Matthew Rahtz wrote:
> > > Thanks for your help Jan,
> > > 
> > > A few months later, we've noticed the issue is actually still there.
> > > Using 3.11.0-17-generic on Ubuntu 12.04, we’re seeing this in the kernel
> > > logs:
> > > 
> > > [29243.606215] WARNING: CPU: 0 PID: 1785 at
> > > /build/buildd/linux-lts-saucy-3.11.0/fs/ext4/ext4_jbd2.c:48
> > > ext4_journal_check_start+0x83/0x90()
> > > 
> > > Having a look at the Ubuntu source package for that version, it
> > > definitely does include commit 03d95eb2f2578083a3f6286262e1cb5d88a00c02,
> > > and the line generating the warning is still:
> > > 
> > > WARN_ON(sb->s_writers.frozen == SB_FREEZE_COMPLETE);
> > > 
> > > Are there any other obvious possibilities for what may be causing this?
> > > There seem to be some users of Oracle Linux experiencing similar problems
> > > at https://community.oracle.com/thread/2617418, which was apparently
> > > fixed in Oracle's kernel version '3.8.13-26.el6uek'. Any word on when
> > > this might be integrated into the official kernel?
> > > 
> > > Full call trace included below.
> >   Looking at the trace below, now the problem seems to be in the NFS server
> > code. NFS should get protection against the filesystem being frozen (or
> > remounted read-only for that matter) via mnt_want_write() before calling
> > into notify_change() (actually before calling fh_lock() because of lock
> > ordering).  Similarly to what we do e.g. in fchownat(). Bruce?
> 
> Like this?
  Yup, that looks right.

> But I wonder why this is just popping up now--as far as I can tell we've
> had the bug since those write counts were introduced.
  Yeah, I'm wondering as well. NFS server on ext4 should have been
complaining for a long time.

								Honza

> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6d7be3f..d573b61 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -445,12 +445,16 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  		err = nfserr_notsync;
>  		goto out_put_write_access;
>  	}
> +	host_err = fh_want_write(fhp);
> +	if (host_err)
> +		goto out_nfserr;
>  
>  	fh_lock(fhp);
>  	host_err = notify_change(dentry, iap, NULL);
>  	fh_unlock(fhp);
> +	fh_drop_write(fhp);
> +out_nfserr:
>  	err = nfserrno(host_err);
> -
>  out_put_write_access:
>  	if (size_change)
>  		put_write_access(inode);
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
