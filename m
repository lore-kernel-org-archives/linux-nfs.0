Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50872 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab2HIUij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 16:38:39 -0400
Date: Thu, 9 Aug 2012 16:38:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Message-ID: <20120809203838.GA11538@fieldses.org>
References: <20120809183557.GA10591@fieldses.org>
 <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com>
 <20120809193743.GD10591@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120809193743.GD10591@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2012 at 03:37:43PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 09, 2012 at 03:06:00PM -0400, Chuck Lever wrote:
> > 
> > On Aug 9, 2012, at 2:35 PM, J. Bruce Fields wrote:
> > 
> > > Sorry not to notice this before--the below causes a regression against
> > > the Linux server; something like:
> > > 
> > > 	# mount -osec=krb5i pip1:/exports /mnt/
> > > 	# echo "test" >/mnt/test
> > > 	# umount /mnt/
> > > 	# mount -osec=krb5 pip1:/exports /mnt/
> > > 	# echo "test" >/mnt/test
> > > 	bash: /mnt/test: Operation not permitted
> > > 
> > > This fails after the below commit on the client, but not before, thanks
> > > to the server rejecting the second setclientid with CLID_INUSE due to a
> > > different security flavor.
> > 
> > This was part of a series where the last few patches got dropped for other problems.  Testing with this patch by itself was never done since it was part of a series of patches that implement a particular feature.
> > 
> > One thought is to put the authentication flavor name back into nfs_client_id4.id string temporarily until we have worked through the issues with full UCS support.  That would prevent the regression, but we'd still have clients who use multiple authentication flavors maintaining multiple leases.
> 
> That should work.

Whoops, no, au_name is just "RPCSEC_GSS" in both cases.

--b.
