Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647Ab2HIVij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 17:38:39 -0400
Date: Thu, 9 Aug 2012 17:38:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Message-ID: <20120809213838.GC11538@fieldses.org>
References: <20120809183557.GA10591@fieldses.org>
 <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com>
 <20120809193743.GD10591@fieldses.org>
 <20120809203838.GA11538@fieldses.org>
 <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
 <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com>
 <20120809211340.GB11538@fieldses.org>
 <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2012 at 05:29:47PM -0400, Chuck Lever wrote:
> 
> On Aug 9, 2012, at 5:13 PM, J. Bruce Fields wrote:
> > The server could just compare principal strings (and ignore
> > pseudoflavors) in the gss case.
> 
> Barring a correction about how GSS Kerberos principals work, I think that's the correct approach.

I also don't know if principals produced by other mechanisms are going
to be comparable.  Of course that's a bit academic given that kerberos
is the only mechanism for the forseeable future.

> > If the intention is to ensure that a clientid can't be "hijacked" by
> > someone malicious, then you don't want to allow a krb5 setclientid to
> > blow away a clientid established with krb5i.  (If sending the
> > setclientid with krb5i indicates the client wants protection against
> > attacks which replace the body of the rpc, then a later krb5 setclientid
> > should be rejected, since it could be the product of such an attack.)
> 
> If the client wants to avoid hijacking, it should start out with krb5i, as is recommended in the Security Considerations section of 3530(bis).
> 
> The intention of 3530(bis) is that one client instance uses just one nfs_client_id4.id string.  A client that attempts to change flavors on its SETCLIENTID/RENEW operations in mid-journey, on purpose, seems a little schizophrenic.  I can't think of a good reason it should do this.

You don't know it's the same client any more.  The attack is:

	client sends setclientid with krb5i.

	client later sends some other rpc with krb5.

	attacker intercepts that operation, takes the rpc header, strips
	out the body, and replaces the body by a setclientid operation
	destroying the client's state.

Since krb5 only protects the header, the server can't tell that's what's
happened.

--b.
