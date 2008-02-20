From: Eric Paris <eparis@redhat.com>
Subject: Re: NFS/LSM: allow NFS to control all of its own mount options
Date: Wed, 20 Feb 2008 08:56:58 -0500
Message-ID: <1203515818.2928.138.camel@localhost.localdomain>
References: <1203457094.2928.113.camel@localhost.localdomain>
	 <20080219222408.GB10656@infradead.org>
	 <E1JRlsG-0004UB-H4@pomaz-ex.szeredi.hu>
	 <1203515410.9902.128.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Miklos Szeredi <miklos@szeredi.hu>, hch@infradead.org,
	linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, jmorris@namei.org, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com,
	linux-fsdevel@vger.kernel.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755443AbYBTN6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 08:58:24 -0500
In-Reply-To: <1203515410.9902.128.camel-/ugcdrsPCSfIm9DtXLC9OUVfdvkotuLY+aIohriVLy8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 08:50 -0500, Stephen Smalley wrote:
> On Wed, 2008-02-20 at 11:08 +0100, Miklos Szeredi wrote:
> > > Please don't introduce a special case for just nfs.  All filesystems
> > > should control their mount options, so please provide some library
> > > helpers for context= handling and move it into all filesystems that
> > > can support selinux.
> > 
> > Hmm, looks like selinux is not showing it's mount options in
> > /proc/mounts.  Well, actually there's no infrastructure for it either.
> > Here's a template patch (completely untested).
> 
> I think the intent is to use the security_sb_get_mnt_opts() hook for
> this purpose.

It was.  I already knew about this issue and its 'on my list.'  Although
I guess we need a something ?new LSM hook? which will translate the
sb_get_mnt_opts stuff into a single text string.  Or I guess really that
can be done in you sb_show_options and I can just use sb_get_mnt_opts
under the covers.  Anyway, unrelated issue that will get fixed as soon
as this real BUG() is fixed.

-Eric

