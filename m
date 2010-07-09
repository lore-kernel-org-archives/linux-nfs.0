From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 04/10] SELinux: Add new labeling type native labels
Date: Fri, 09 Jul 2010 10:09:26 -0400
Message-ID: <1278684566.2494.226.camel@moss-terrapins.epoch.ncsc.mil>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>
	 <alpine.LRH.2.00.1007080921200.14102@tundra.namei.org>
	 <1278595878.2494.186.camel@moss-terrapins.epoch.ncsc.mil>
	 <alpine.LRH.2.00.1007090824150.23354@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, "Matthew N. Dodd" <matthew.dodd@sparta.com>,
	trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007090824150.23354@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-07-09 at 08:33 +1000, James Morris wrote:
> On Thu, 8 Jul 2010, David P. Quigley wrote:
> 
> > > Otherwise, this is a global policy decision which affects all NFSv4 
> > > mounts, right?
> > > 
> > > 
> > 
> > I don't believe we have that ability in any other file system.
> 
> NFS is quite different to other filesystems.  Your files are on other 
> systems, for example, which may or may not support security labeling.

And if that is the case then the capability flag does not get set in the
NFSv4 server caps and we don't use security label support on that mount.

> 
> > If you want to decide that you want to use genfs style labels on NFSv4 
> > just use a context mount.
> 
> So, we enable this feature, and virtually all existing mounts break 
> because the servers do not support labeling.

No it should default back to being nfs_t which is what happens when I
use my client on an export that doesn't have security_label set.

> 
> > That way you can have the default behavior be 
> > use security label support unless you don't want to and then you can 
> > have a context mount.
> 
> It needs to be the other way around.  This is a new feature, so the 
> default needs to be the existing behavior, with security labeling as an 
> option to enable at mount time.

We made sure it falls back properly. It was decided a long time ago with
discussion by several people that having it default to use it if its
there otherwise fall back to the old behavior makes much more sense to
an administrator.

> 
> 
> 
> - James

