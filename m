Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12290 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566Ab0FWS6l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 14:58:41 -0400
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: James Morris <jmorris@namei.org>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Christoph Hellwig <hch@infradead.org>,
        Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <20100623183542.GC28346@fieldses.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
	 <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>
	 <4C1FC553.4030904@oracle.com>
	 <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org>
	 <4C20D779.5040008@oracle.com>
	 <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org>
	 <20100623183542.GC28346@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Jun 2010 14:58:17 -0400
Message-ID: <1277319497.4991.41.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-06-23 at 14:35 -0400, J. Bruce Fields wrote:
> On Wed, Jun 23, 2010 at 10:26:18AM +1000, James Morris wrote:
> > On Tue, 22 Jun 2010, Chuck Lever wrote:
> > 
> > > Another place to look is at NFSv4.  Some of the operations that can be
> > > performed on NFSv4 xattrs are probably nearly what you would want for an NFSv3
> > > implementation.  I think it is desirable for anything done for NFSv3 to be
> > > compatible with NFSv4, as that is already a standard.
> > 
> > Are you referring to named attributes?  I've looked into this, as have 
> > others, and they appear to be fundamentally incompatible with Linux/BSD 
> > xattrs.  They're filesystems within files, with different semantics to the 
> > name/value string model that we use.  I've heard a few developers say 
> > they've looked at implementing xattrs over NAs, but found it unworkable.
> 
> Yes, if we were going to add xattr's to NFSv4, we'd want to define
> entirely new operations for it rather than relying on the named
> attribute mechanism.

Agreed, however there is already work underway in the IETF on the
'labeled NFS' protocol for supporting security labels in NFSv4.

See http://linux-nfs.org/pipermail/labeled-nfs/

Is there really much interest in adding NFSv4 support for xattrs beyond
the security label use case?

Cheers
  Trond
