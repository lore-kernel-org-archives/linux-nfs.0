Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33057 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965011Ab2CSQ2z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 12:28:55 -0400
Date: Mon, 19 Mar 2012 12:28:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120319162851.GA22336@fieldses.org>
References: <87pqchn64e.fsf@inspiron.ap.columbia.edu>
 <20120312193115.GA7203@fieldses.org>
 <4F5E5241.7070008@rath.org>
 <20120312201505.GC7203@fieldses.org>
 <4F5E5CF2.50309@rath.org>
 <20120312204238.GA8991@fieldses.org>
 <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
 <20120312210414.GB8991@fieldses.org>
 <D62C59BB-D68B-42FD-A916-78B86C1133F7@oracle.com>
 <20120312212708.GC8991@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120312212708.GC8991@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 05:27:08PM -0400, J. Bruce Fields wrote:
> On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
> > IMO, the server should do a comparison of the nfs_client_id4 strings,
> > and nothing else.
> 
> We're supposed to return CLID_INUSE when we see a setclientid from a
> "different" client using the same string, to keep clients from doing
> mischief with other clients' state (either maliciously or, as in this
> case, accidentally).
> 
> "Different" here is defined as "not having the same principal".  I know
> what that means in the krb5 case, but I'm less certain in the auth_sys
> case.

Cc'ing the ietf list.  Is it reasonable for a server to expect
setclientid's to come from the same client IP address at least in the
auth_sys case, or could that break multi-homed clients?

At least in the auth_sys case IP addresses are one of the only things we
have left to go on when the client's identifier-generation is messed up
(not that difficult).

--b.
