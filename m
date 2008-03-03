From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH -v2] NFS/LSM: allow NFS to control all of its own mount
	options
Date: Mon, 03 Mar 2008 15:10:55 -0500
Message-ID: <1204575055.3216.49.camel@localhost.localdomain>
References: <1204573372.3216.42.camel@localhost.localdomain>
	 <1204573122.14520.90.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	casey@schaufler-ca.com, trond.myklebust@fys.uio.no,
	chuck.lever@oracle.com, hch@infradead.org
To: Dave Quigley <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756083AbYCCUNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2008 15:13:52 -0500
In-Reply-To: <1204573122.14520.90.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-03-03 at 14:38 -0500, Dave Quigley wrote:
> > This patch was tested with NFSv3 mounts and solves all of the
> > regressions that have been introduced in the NFS code.  It supports both
> > the binary interface and text options without pushing LSM specific
> > parsing into the FS.  It doesn't introduce the new LSM constructs
> > necessary to show these mount options in /proc/mounts suggested by
> > Miklos Szeredi but that will be coming in 2.6.26 (it's not a regression
> > or bug fix).  I also do not have the proper security_sb_set_mnt_opts()
> > call in nfs4_get_sb due to a lack of a testing environment, but will add
> > that in 2.6.26 as well.
>
> I see above that the patch does not provide this support for NFSv4. Do
> you intend on adding this in the future or is it being deferred to
> someone else?

I believe it is just the very same addition to nfs4_get_sb() that i did
in nfs_get_sb and plan to test and do that myself in the next release.
I'm just trying to make this patch as absolutely small as possible while
still fixing all the problems to get it into 2.6.25.

-Eric

