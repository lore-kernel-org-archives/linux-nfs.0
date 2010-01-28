Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:37624 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755062Ab0A1JFO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 04:05:14 -0500
Date: Thu, 28 Jan 2010 20:05:04 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSv3: add client implementation of XATTR protocol
In-Reply-To: <F8499EC3-5B8A-4840-99A7-79B0E984FBF5@oracle.com>
Message-ID: <alpine.LRH.2.00.1001281921150.27746@tundra.namei.org>
References: <alpine.LRH.2.00.1001270952420.15158@tundra.namei.org> <alpine.LRH.2.00.1001271008370.15158@tundra.namei.org> <F8499EC3-5B8A-4840-99A7-79B0E984FBF5@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 27 Jan 2010, Chuck Lever wrote:

> I haven't followed this closely, but two questions come to mind when reading
> this:
> 
> a)  why would a distro (or admin building their own kernels) want to disable
> this?  iow why not leave the capability always built in?

Some people may want to save memory, and it's in keeping with config 
options for similar features such as ACLs.

> 
> b)  why is the side protocol not compatible with IRIX?  wouldn't the IRIX
> protocol be a de facto standard?  did you mention before whether there were
> other implementations we _should_ be wire compatible with?

I started out hoping to make it compatible with IRIX, but there are a 
couple of issues:

- They use a cursor-based scheme for listxattr, which we don't support at 
  the xattr API level.  If we want wire-compatibility, we could ignore 
  the cursor field, or try and detect that the client is using it and 
  return an error.

- We use arbitrary text namespaces, whereas they indicate xattr types
  via flags.  Technically, we could try and use only the IRIX format:
  e.g. only use their flags when talking to an IRIX box, and otherwise 
  concatenate our xattr namespace and names on the wire.

In both cases, we need to detect that we're talking to an IRIX system 
and then alter the way we handle the protocol.  It also makes our 
implementation more complicated than necessary, and it's not clear to me 
what level of demand there is for IRIX and Linux interop for NFSv3.

So, my suggestion would be to implement the protocol in a way which is 
optimized for Linux, and then look at adding a separate IRIX compatibility 
option which:

 - uses a distinct protocol number (the existing IRIX one);
 - is wire-compatible;
 - handles the cursor field somehow; and 
 - only supports actual IRIX xattr types.

i.e. an option to support legacy IRIX clients.  I don't think there's any 
point in trying to support IRIX servers.  It keeps the overall code 
cleaner, and avoids optimizing for what might be a marginal use case.

I don't know of any other open implementations of xattrs for NFSv3.


- James
-- 
James Morris
<jmorris@namei.org>
