Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57113 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab2HJUNu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 16:13:50 -0400
Date: Fri, 10 Aug 2012 16:13:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Message-ID: <20120810201348.GB17985@fieldses.org>
References: <20120809183557.GA10591@fieldses.org>
 <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com>
 <20120809193743.GD10591@fieldses.org>
 <20120809203838.GA11538@fieldses.org>
 <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
 <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com>
 <20120809211340.GB11538@fieldses.org>
 <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com>
 <20120809213838.GC11538@fieldses.org>
 <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 03:38:30PM -0400, Chuck Lever wrote:
> 
> On Aug 9, 2012, at 5:38 PM, J. Bruce Fields wrote:
> 
> > On Thu, Aug 09, 2012 at 05:29:47PM -0400, Chuck Lever wrote:
> >> 
> >> On Aug 9, 2012, at 5:13 PM, J. Bruce Fields wrote:
> >>> The server could just compare principal strings (and ignore
> >>> pseudoflavors) in the gss case.
> >> 
> >> Barring a correction about how GSS Kerberos principals work, I think that's the correct approach.
> > 
> > I also don't know if principals produced by other mechanisms are going
> > to be comparable.  Of course that's a bit academic given that kerberos
> > is the only mechanism for the forseeable future.
> 
> Agreed, I would expect this to work only for pseudoflavors that share the same type of principal.
> 
> Let me be sure I understand... I think the text of RFC 3530bis allows this implementation choice, but you are suggesting below that such an implementation may allow an attack.  Does this concern warrant a change to RFC 3530bis or 5661?  Should we bring this up on nfsv4@ietf.org?

This should be all completely settled in 4.1.  It's 4.0 that I'm
confused by.

What do you need the client to be able to do?  Does it need to be able
to perform setclientid's on the same client with different security
flavors?

In this particular case (mount/umount with one flavor, then mount/umount
with another), maybe the client should destroy the client state (with an
"I rebooted" setclientid) on the first umount?  (I thought you had
patches that did that?)

--b.

> 
> > 
> >>> If the intention is to ensure that a clientid can't be "hijacked" by
> >>> someone malicious, then you don't want to allow a krb5 setclientid to
> >>> blow away a clientid established with krb5i.  (If sending the
> >>> setclientid with krb5i indicates the client wants protection against
> >>> attacks which replace the body of the rpc, then a later krb5 setclientid
> >>> should be rejected, since it could be the product of such an attack.)
> >> 
> >> If the client wants to avoid hijacking, it should start out with krb5i, as is recommended in the Security Considerations section of 3530(bis).
> >> 
> >> The intention of 3530(bis) is that one client instance uses just one nfs_client_id4.id string.  A client that attempts to change flavors on its SETCLIENTID/RENEW operations in mid-journey, on purpose, seems a little schizophrenic.  I can't think of a good reason it should do this.
> > 
> > You don't know it's the same client any more.  The attack is:
> > 
> > 	client sends setclientid with krb5i.
> > 
> > 	client later sends some other rpc with krb5.
> > 
> > 	attacker intercepts that operation, takes the rpc header, strips
> > 	out the body, and replaces the body by a setclientid operation
> > 	destroying the client's state.
> > 
> > Since krb5 only protects the header, the server can't tell that's what's
> > happened.
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
