Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.65.39]:59381 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189Ab0GHNj1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 09:39:27 -0400
Subject: Re: [PATCH 04/10] SELinux: Add new labeling type native labels
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, "Matthew N. Dodd" <matthew.dodd@sparta.com>,
        trond.myklebust@fys.uio.no, bfields@fieldses.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
In-Reply-To: <alpine.LRH.2.00.1007080921200.14102@tundra.namei.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>
	 <alpine.LRH.2.00.1007080921200.14102@tundra.namei.org>
Content-Type: text/plain
Date: Thu, 08 Jul 2010 09:31:18 -0400
Message-Id: <1278595878.2494.186.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-08 at 09:23 +1000, James Morris wrote:
> On Wed, 7 Jul 2010, David P. Quigley wrote:
> 
> > There currently doesn't exist a labeling type that is adequate for use with
> > labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
> > labeling behavior. For this we developed a new labeling type. The native
> > labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
> > by the NFS code instead of relying on the SELinux security server on the client
> > end.
> 
> It would be useful to have the ability to specify labeling behavior on a 
> per-mount basis, with the default remaining as genfs.
> 
> Otherwise, this is a global policy decision which affects all NFSv4 
> mounts, right?
> 
> 

I don't believe we have that ability in any other file system. If you
want to decide that you want to use genfs style labels on NFSv4 just use
a context mount. That way you can have the default behavior be use
security label support unless you don't want to and then you can have a
context mount.


