From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 04/10] SELinux: Add new labeling type native labels
Date: Fri, 9 Jul 2010 08:33:48 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1007090824150.23354@tundra.namei.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>  <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>  <alpine.LRH.2.00.1007080921200.14102@tundra.namei.org> <1278595878.2494.186.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, "Matthew N. Dodd" <matthew.dodd@sparta.com>,
	trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278595878.2494.186.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 8 Jul 2010, David P. Quigley wrote:

> > Otherwise, this is a global policy decision which affects all NFSv4 
> > mounts, right?
> > 
> > 
> 
> I don't believe we have that ability in any other file system.

NFS is quite different to other filesystems.  Your files are on other 
systems, for example, which may or may not support security labeling.

> If you want to decide that you want to use genfs style labels on NFSv4 
> just use a context mount.

So, we enable this feature, and virtually all existing mounts break 
because the servers do not support labeling.

> That way you can have the default behavior be 
> use security label support unless you don't want to and then you can 
> have a context mount.

It needs to be the other way around.  This is a new feature, so the 
default needs to be the existing behavior, with security labeling as an 
option to enable at mount time.



- James
-- 
James Morris
<jmorris@namei.org>
