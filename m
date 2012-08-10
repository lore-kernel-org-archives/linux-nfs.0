Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976Ab2HJUxH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 16:53:07 -0400
Date: Fri, 10 Aug 2012 16:53:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Message-ID: <20120810205305.GD17985@fieldses.org>
References: <20120809203838.GA11538@fieldses.org>
 <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
 <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com>
 <20120809211340.GB11538@fieldses.org>
 <6575B2FD-CCE4-40D5-9CBA-82681EC20E17@oracle.com>
 <20120809213838.GC11538@fieldses.org>
 <B28F4673-3650-4BA9-ADDA-F9A8E62A0499@oracle.com>
 <20120810201348.GB17985@fieldses.org>
 <12DB2C80-31EB-4317-B1E7-96620A8F7374@oracle.com>
 <20120810203930.GC17985@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120810203930.GC17985@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 04:39:30PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 10, 2012 at 04:33:46PM -0400, Chuck Lever wrote:
> > OK, I didn't notice that you were unmounting between the tests.  3.5 and before did update the boot verifier after the last mount of a server goes away, but that's also not desirable behavior.  So I guess 3.6 also has my patch which makes the NFS client use the same boot verifier until it reboots, as God and the authors of 3530 intended?
> 
> I don't know.  (Why is that the right thing to do?  Telling the server
> when you're not using the client any more seems reasonable to me.)

And anyway can't the trick described in

	2c820d9a97f07b273b2c8a5960bd52b1b5864c68 "NFS: Force server to
	drop NFSv4 state"

be used to do that without changing the boot verifier?

--b.
