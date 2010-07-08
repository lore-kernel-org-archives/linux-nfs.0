Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:47031 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755969Ab0GHWsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 18:48:55 -0400
Date: Fri, 9 Jul 2010 08:48:34 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
cc: "J. Bruce Fields" <bfields@fieldses.org>, hch@infradead.org,
        viro@zeniv.linux.org.uk, casey@schaufler-ca.com, sds@tycho.nsa.gov,
        matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
 flags
In-Reply-To: <1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
Message-ID: <alpine.LRH.2.00.1007090834190.23354@tundra.namei.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>  <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>  <20100707170058.GD28815@fieldses.org>  <alpine.LRH.2.00.1007080928180.14102@tundra.namei.org>
 <1278596363.2494.194.camel@moss-terrapins.epoch.ncsc.mil>
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 8 Jul 2010, David P. Quigley wrote:

> > The maximum security label size on Linux is:
> > 
> > #define XATTR_SIZE_MAX 65536
> > 
> > Why arbitrarily limit this over the network?
> 
> Because there is no easy way not to. The specification doesn't specify a
> limit to label size in the IETF draft. However there is no way to do
> allocation of the memory needed to store the label where we first get
> access to its size. We tried this before and it failed. When I asked
> trond about it he said doing memory allocation in the rpc context isn't
> allowed.

In the NFSv3 code, the workaround I've been using is to always allocate 
64k, but the correct way of doing this apparently is to use the page 
cache, as is used for ACLs and symlinks.

> For the most part what would make this label size inadequate would be 
> the MLS component. There are some cases where people want every other 
> compartment or something crazy like that. In terms of a normal label 
> though 4096 should be more than enough.

Yes, but we should not unnecessarily limit the network protocol when 
something is valid and possible in the local implementation (which is ~64k 
under Linux).

> Just to put this in perspective the string below is 4096 a's.

A security label include just about anything, e.g. an x509 certificate, or 
a base64 encoded image.

In the Linux implementation, if we can store a local label up to 64k, then 
we should try and ensure that it can be conveyed via NFS.



- James
-- 
James Morris
<jmorris@namei.org>
