Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:56915 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab0GINsR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jul 2010 09:48:17 -0400
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
 flags
From: Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Cc: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        "J. Bruce Fields" <bfields@fieldses.org>, hch@infradead.org,
        viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
In-Reply-To: <alpine.LRH.2.00.1007090834190.23354@tundra.namei.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
	 <20100707170058.GD28815@fieldses.org>
	 <alpine.LRH.2.00.1007080928180.14102@tundra.namei.org>
	 <1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
	 <alpine.LRH.2.00.1007090834190.23354@tundra.namei.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 09 Jul 2010 09:47:50 -0400
Message-ID: <1278683270.13292.10.camel@moss-pluto.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-07-09 at 08:48 +1000, James Morris wrote:
> On Thu, 8 Jul 2010, David P. Quigley wrote:
> 
> > > The maximum security label size on Linux is:
> > > 
> > > #define XATTR_SIZE_MAX 65536
> > > 
> > > Why arbitrarily limit this over the network?
> > 
> > Because there is no easy way not to. The specification doesn't specify a
> > limit to label size in the IETF draft. However there is no way to do
> > allocation of the memory needed to store the label where we first get
> > access to its size. We tried this before and it failed. When I asked
> > trond about it he said doing memory allocation in the rpc context isn't
> > allowed.
> 
> In the NFSv3 code, the workaround I've been using is to always allocate 
> 64k, but the correct way of doing this apparently is to use the page 
> cache, as is used for ACLs and symlinks.
> 
> > For the most part what would make this label size inadequate would be 
> > the MLS component. There are some cases where people want every other 
> > compartment or something crazy like that. In terms of a normal label 
> > though 4096 should be more than enough.
> 
> Yes, but we should not unnecessarily limit the network protocol when 
> something is valid and possible in the local implementation (which is ~64k 
> under Linux).
> 
> > Just to put this in perspective the string below is 4096 a's.
> 
> A security label include just about anything, e.g. an x509 certificate, or 
> a base64 encoded image.
> 
> In the Linux implementation, if we can store a local label up to 64k, then 
> we should try and ensure that it can be conveyed via NFS.

You can't store a local label up to 64k on Linux; that is just what the
xattr API permits, not the underlying filesystem implementations (at
least ext[234]).

# touch foobar
# setfattr -n user.foo -v `perl -e 'print "a" x 4096'` foobar
setfattr: foobar: No space left on device

Also the /proc/self/attr and selinuxfs APIs are presently limited to
page size.

-- 
Stephen Smalley
National Security Agency

