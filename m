From: Brad Boyer <flar@allandria.com>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol (XATTR)
Date: Fri, 12 Mar 2010 23:28:59 -0800
Message-ID: <20100313072859.GA2779@cynthia.pants.nu>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu> <alpine.LRH.2.00.1003091834450.12164@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1003091834450.12164@tundra.namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 09, 2010 at 07:13:45PM +1100, James Morris wrote:
> The core issue is that we don't want system-level xattrs being stored on 
> the server.

I can understand that, but it does seem like only system xattrs should
be treated that way to me.

> As you suggest, perhaps we always leave 'user' xattrs untranslated on the 
> server, with an expectation that they're always opaque to the server and 
> managed entirely by user applications.

This seems reasonable.

> I don't think we can meaningfully do this for 'trusted' xattrs, as we 
> don't know how to extend CAP_SYS_ADMIN over NFS.  So, this, and all other 
> non-user namespaces (e.g. 'system', 'security') are mapped on the server 
> to the 'nfsd' namespace, on the basis that they would otherwise require 
> interpretation by the server, which we want to avoid.  (Note that there's 
> an exception here for POSIX ACLs, which already use a well-defined 
> protocol over NFS).
> 
> Here's a summary of the mappings:
> 
> Client                    Server
> 
> user.a                    user.a
> trusted.a                 nfsd.trusted.a
> system.a                  nfsd.system.a
> security.a                nfsd.security.a
> 
> Special cases:
> 
>   if ACL protocol enabled on server:
> 
> system.posix_acl_access   system.posix_acl_access
> system.posix_acl_default  system.posix_acl_default
>   
>   if ACL protocol not enabled on server:
> 
> system.posix_acl_access   [error]
> system.posix_acl_default  [error]
> 
> This also ensures that nothing about the existing NFS ACL support changes.
> 
> 'user' xattrs simply work as expected, whether accessed locally or 
> remotely.  
> 
> How does this sound?

This mapping sounds great to me. It would be interesting to hear some
opinions from other people on the lists.

	Brad Boyer
	flar@allandria.com

