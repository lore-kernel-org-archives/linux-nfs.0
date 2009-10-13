From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 13 Oct 2009 14:27:24 -0400
Message-ID: <1255458444.3711.113.camel@heimdal.trondhjem.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
	 <4ACB5FC0.7060307@redhat.com>
	 <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>
	 <4AD36C82.8080904@redhat.com>
	 <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>
	 <4AD384BE.2090008@redhat.com>
	 <1255388158.3711.57.camel@heimdal.trondhjem.org>
	 <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:33463 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760454AbZJMS2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 14:28:13 -0400
In-Reply-To: <alpine.LRH.2.00.0910131733070.28896-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-10-13 at 18:02 +1100, James Morris wrote:
> This xattr approach would only cover the "dumb server" scenario, where the 
> server simply stores and retrieves security labels on behalf of the 
> client.  It's intended primarily to enable things like nfsroot, backups, 
> serving virtualized file systems etc., and not for fully trusted sharing 
> like Labeled NFS.
> 
> It is essentially just security label transport.
> 
> Support for this feature would be configured at the server, possibly an 
> option in /etc/exports which enables specific security namespaces, e.g:
> 
>   /opt/share   10.0.0.0/8(rw,insecure,xattr="user.*,security.SMACK64")
> 
> This says that the XATTR side protocol is enabled and clients can read and 
> write user and security.smack xattrs (local DAC would be applied to both).
> 
> The server kernel would likely need to know that these are foreign labels, 
> and not necessarily 'trust' them for its own use, so a root_squash -like 
> option may be used to remap them to an 'untrusted' local label for local 
> enforcement purposes -- if it was running SELinux or Smack at all, which 
> it may not be.

Fair enough. That might indeed work.

One simple alternative might be to just store the exported xattrs in
something other than the 'security' extended attribute namespace so that
your server processes don't have to deal with any conflicts.

IOW: maybe add a 'nfs.security' xattr namespace, which would contain
those security labels that are actually exported by this XATTR protocol,
and which the clients could then translate into their local 'security'
labels.
You might even be able to store per-client security labels as something
like 'nfs.$(hostname).security', or perhaps have a namespace like
'nfs.fedora11.security' that applies to all clients running fedora?

> At the top of my todo list is to document the XATTR protocol -- I'll also 
> draft a specification for the security namespace along these lines.

Thanks! That would be good.

Trond

