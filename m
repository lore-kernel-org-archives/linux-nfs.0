From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Thu, 21 Jan 2010 14:15:15 -0500
Message-ID: <20100121191515.GA22021@fieldses.org>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com> <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com> <20100120082905.1825f806@tlielax.poochiereds.net> <8E556CE2-569B-4E6D-BD02-7EF5CA84900D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	steved@redhat.com, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46712 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754019Ab0AUTNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 14:13:53 -0500
In-Reply-To: <8E556CE2-569B-4E6D-BD02-7EF5CA84900D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 20, 2010 at 10:36:36AM -0500, Chuck Lever wrote:
> For the record, we looked at Solaris behavior yesterday.  With bi-family 
> servers, its mount command tries IPv6 first, but appears smart enough to 
> fall back to IPv4.  One thing we haven't tried is to see how difficult it 
> would be to fix the real problem by adding proper protocol family 
> negotiation to our own mount command.

Sorry, I probably just haven't been following: what's "proper protocol
family negotiation"?  I thought the only ways to negotiate were either
rpcbind (v2, v3) or trial and error (v4)?

--b.
