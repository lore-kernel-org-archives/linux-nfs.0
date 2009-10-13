From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 13 Oct 2009 18:02:42 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>  <4ACB5FC0.7060307@redhat.com>  <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>  <4AD36C82.8080904@redhat.com>  <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>  <4AD384BE.2090008@redhat.com>
 <1255388158.3711.57.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Staubach <staubach@redhat.com>, Tom Haynes <tdh@excfb.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1255388158.3711.57.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Oct 2009, Trond Myklebust wrote:

> I don't see how it can be anything but a Linux to Linux, single
> distribution only solution if you support setting and clearing 'system'
> and 'security' extended attributes, since there appears to be no method
> outlined here for negotiating which features the client and server
> support.

I've been focused on the basic protocol implementation for the user 
namespace thus far, to see if the general approach is acceptable before 
getting too deep into support for other namespaces.

Interop for other namespaces will vary depending on their semantics -- see 
below for my ideas on the security namespace.

> Without such negotiation (or the requirement that the client and server
> be completely homogeneous), how do I, for instance, stop the
> 'restorecon' utility running on my client from breaking my mail server
> process running on a completely different machine when it decides to
> reset the 'security.selinux' label on my ~/mail folder?

This xattr approach would only cover the "dumb server" scenario, where the 
server simply stores and retrieves security labels on behalf of the 
client.  It's intended primarily to enable things like nfsroot, backups, 
serving virtualized file systems etc., and not for fully trusted sharing 
like Labeled NFS.

It is essentially just security label transport.

Support for this feature would be configured at the server, possibly an 
option in /etc/exports which enables specific security namespaces, e.g:

  /opt/share   10.0.0.0/8(rw,insecure,xattr="user.*,security.SMACK64")

This says that the XATTR side protocol is enabled and clients can read and 
write user and security.smack xattrs (local DAC would be applied to both).

The server kernel would likely need to know that these are foreign labels, 
and not necessarily 'trust' them for its own use, so a root_squash -like 
option may be used to remap them to an 'untrusted' local label for local 
enforcement purposes -- if it was running SELinux or Smack at all, which 
it may not be.

At the top of my todo list is to document the XATTR protocol -- I'll also 
draft a specification for the security namespace along these lines.


- James
-- 
James Morris
<jmorris@namei.org>
