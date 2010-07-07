Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:50370 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756870Ab0GGXXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 19:23:41 -0400
Date: Thu, 8 Jul 2010 09:23:23 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, "Matthew N. Dodd" <matthew.dodd@sparta.com>,
        trond.myklebust@fys.uio.no, bfields@fieldses.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/10] SELinux: Add new labeling type native labels
In-Reply-To: <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>
Message-ID: <alpine.LRH.2.00.1007080921200.14102@tundra.namei.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov> <1278513086-23964-5-git-send-email-dpquigl@tycho.nsa.gov>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Jul 2010, David P. Quigley wrote:

> There currently doesn't exist a labeling type that is adequate for use with
> labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
> labeling behavior. For this we developed a new labeling type. The native
> labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
> by the NFS code instead of relying on the SELinux security server on the client
> end.

It would be useful to have the ability to specify labeling behavior on a 
per-mount basis, with the default remaining as genfs.

Otherwise, this is a global policy decision which affects all NFSv4 
mounts, right?


-- 
James Morris
<jmorris@namei.org>
