Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56034 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757345Ab2CLV1L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 17:27:11 -0400
Date: Mon, 12 Mar 2012 17:27:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120312212708.GC8991@fieldses.org>
References: <878vj7x6mj.fsf@vostro.rath.org>
 <87pqchn64e.fsf@inspiron.ap.columbia.edu>
 <20120312193115.GA7203@fieldses.org>
 <4F5E5241.7070008@rath.org>
 <20120312201505.GC7203@fieldses.org>
 <4F5E5CF2.50309@rath.org>
 <20120312204238.GA8991@fieldses.org>
 <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
 <20120312210414.GB8991@fieldses.org>
 <D62C59BB-D68B-42FD-A916-78B86C1133F7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D62C59BB-D68B-42FD-A916-78B86C1133F7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
> IMO, the server should do a comparison of the nfs_client_id4 strings,
> and nothing else.

We're supposed to return CLID_INUSE when we see a setclientid from a
"different" client using the same string, to keep clients from doing
mischief with other clients' state (either maliciously or, as in this
case, accidentally).

"Different" here is defined as "not having the same principal".  I know
what that means in the krb5 case, but I'm less certain in the auth_sys
case.

> The client IP addresses are unreliable.  Otherwise,
> why have an nfs_client_id4 string to begin with?  And how could a
> multi-homed client ever word?

I don't know.  Is it expected that such clients would do setclientid's
over different interfaces and expect it to work?

(I'm trying to remember now how we identify clients for the purposes of
NSM.  In the auth_sys case maybe the goal should be to keep things
working more or less as they did with auth_sys under v2/v3.)

> Maybe I don't understand what you mean.
> 
> But, anyway, if the clients are all using the same nfs_client_id4
> string, that's going to cause no end of trouble, since the boot
> verifier for each of these clients is bound to be different.  When the
> server sees a boot verifier change, it will just drop all the client's
> state.  Each client's SETCLIENTID will trash the state of anything
> that came before attached to that nfs_client_id4.  That will result in
> the clients all constantly trying to recover state.

Yes, looks like something like that is happening.

This is probably a case of a slightly exotic (and possibly broken in
some sense) client network setup--but those may turn out to be more
common than we'd like.

--b.

> I suppose the
> server could watch for a boot verifier replay (cel ducks)
