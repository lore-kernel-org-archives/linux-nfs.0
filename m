From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: NFS/LSM: allow NFS to control all of its own mount options
Date: Wed, 20 Feb 2008 08:48:28 -0500
Message-ID: <1203515308.9902.126.camel@moss-spartans.epoch.ncsc.mil>
References: <1203457094.2928.113.camel@localhost.localdomain>
	 <20080219222408.GB10656@infradead.org>
	 <Xine.LNX.4.64.0802201114030.2475@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	Eric Paris <eparis@redhat.com>, linux-nfs@vger.kernel.org,
	selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, casey@schaufler-ca.com,
	trond.myklebust@fys.uio.no, chuck.lever@oracle.com,
	linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <Xine.LNX.4.64.0802201114030.2475@us.intercode.com.au>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-20 at 11:25 +1100, James Morris wrote:
> On Tue, 19 Feb 2008, Christoph Hellwig wrote:
> 
> > Please don't introduce a special case for just nfs.  All filesystems
> > should control their mount options, so please provide some library
> > helpers for context= handling and move it into all filesystems that
> > can support selinux.
> 
> It's not so much a special case for NFS, just that NFS happens to use 
> binary mount options.  So, I guess it could be put into a library for 
> other potential filesystems with binary mount options.
> 
> To clarify:
> 
> The SELinux options are indeed filesystem independent, and the FS should 
> really not need to be concerned at all with them.  For everything except 
> NFS, we parse text options looking for context=, then use that value from 
> within SELinux as the label for all files in the mount.
> 
> Previously, as Eric mentions, we were using a method initially approved by 
> the NFS folk, where, for NFS, SELinux was peeking around inside the binary 
> options.  We were then asked to change that so that NFS (or other 
> binary-option FS) would obtain the values itself and call into LSM with 
> them.  This is what Eric's latest patch enables (a previous patch 
> installed the infrastructure for it).
> 
> While this code could be put into a library if desired, there is no need 
> to make any changes for filesystems with text options (i.e. the general 
> case).

And to be clear:  this patch fixes a real bug in the nfs/selinux
interaction on nohide mounts, a bug that needs to be fixed upstream as
soon as possible.  A bug that was introduced by changes in nfs, not
changes in selinux AFAIK, given that the original approach to context
mounts was introduced and approved by nfs folks long ago.  So regardless
of what happens wrt the text mount options, this patch needs to get
merged.

-- 
Stephen Smalley
National Security Agency

