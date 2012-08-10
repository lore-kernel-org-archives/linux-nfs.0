Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645Ab2HJUjb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 16:39:31 -0400
Date: Fri, 10 Aug 2012 16:39:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Message-ID: <20120810203930.GC17985@fieldses.org>
References: <20120809193743.GD10591@fieldses.org>
 <20120809203838.GA11538@fieldses.org>
 <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
 <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com>
 <20120809211340.GB11538@fieldses.org>
 <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com>
 <20120809213838.GC11538@fieldses.org>
 <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com>
 <20120810201348.GB17985@fieldses.org>
 <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 04:33:46PM -0400, Chuck Lever wrote:
> OK, I didn't notice that you were unmounting between the tests.  3.5 and before did update the boot verifier after the last mount of a server goes away, but that's also not desirable behavior.  So I guess 3.6 also has my patch which makes the NFS client use the same boot verifier until it reboots, as God and the authors of 3530 intended?

I don't know.  (Why is that the right thing to do?  Telling the server
when you're not using the client any more seems reasonable to me.)

> I think we agree that, whether the Linux server is compliant with what's currently in 3530bis or not, it's the NFS client changes in 3.6 that "introduced the regression" and should be fixed.  If you change the client to add the flavor and pseudoflavor name to the nfs_client_id4.id string, does that fix the regression satisfactorily?

I haven't tested it, but yes, that should do the job.

(Though note that's not just a revert, since previously only the flavor
(not the pseudoflavor) was factored into the clientid string.)

--b.

> 
> Maybe we should just revert those two and try again in 3.7.
> 
> > --b.
> > 
> >> 
> >>> 
> >>>>> If the intention is to ensure that a clientid can't be "hijacked" by
> >>>>> someone malicious, then you don't want to allow a krb5 setclientid to
> >>>>> blow away a clientid established with krb5i.  (If sending the
> >>>>> setclientid with krb5i indicates the client wants protection against
> >>>>> attacks which replace the body of the rpc, then a later krb5 setclientid
> >>>>> should be rejected, since it could be the product of such an attack.)
> >>>> 
> >>>> If the client wants to avoid hijacking, it should start out with krb5i, as is recommended in the Security Considerations section of 3530(bis).
> >>>> 
> >>>> The intention of 3530(bis) is that one client instance uses just one nfs_client_id4.id string.  A client that attempts to change flavors on its SETCLIENTID/RENEW operations in mid-journey, on purpose, seems a little schizophrenic.  I can't think of a good reason it should do this.
> >>> 
> >>> You don't know it's the same client any more.  The attack is:
> >>> 
> >>> 	client sends setclientid with krb5i.
> >>> 
> >>> 	client later sends some other rpc with krb5.
> >>> 
> >>> 	attacker intercepts that operation, takes the rpc header, strips
> >>> 	out the body, and replaces the body by a setclientid operation
> >>> 	destroying the client's state.
> >>> 
> >>> Since krb5 only protects the header, the server can't tell that's what's
> >>> happened.
> >> 
> >> -- 
> >> Chuck Lever
> >> chuck[dot]lever[at]oracle[dot]com
> >> 
> >> 
> >> 
> >> 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
