Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398Ab3JIQ24 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Oct 2013 12:28:56 -0400
Date: Wed, 9 Oct 2013 12:28:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Coffman Kevin <kwc@citi.umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: unread variables in sunrpc kerberos code
Message-ID: <20131009162838.GA29734@pad.fieldses.org>
References: <20130930183926.GB6931@two.firstfloor.org>
 <20131004031643.GA13502@two.firstfloor.org>
 <20131004062915.48772e4b@tlielax.poochiereds.net>
 <DD6C34BD-1F21-4355-BE73-56538E5B29D4@netapp.com>
 <20131007131237.GA20881@pad.fieldses.org>
 <20131008222029.GP6882@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131008222029.GP6882@two.firstfloor.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding the linux-nfs list on the cc in case somebody else has looked at
this more recently than me....

On Wed, Oct 09, 2013 at 12:20:29AM +0200, Andi Kleen wrote:
> > I think it's probably harmless, though it wouldn't be a bad idea to
> > review it if somebody had the time.
>
> Can you explain why it is harmless? Is the sequence number
> checked elsewhere? If yes, where?

I really don't remember.

OK, I give in, I'll go look:

RFC 1964 section 1.2.1.2 says

	The sequence number provides a basis for detection of replayed
	tokens.  Replay detection *can* be performed using state
	information retained on received sequence numbers...

(emphasis mine), and

	Provision of per-message replay and out-of-sequence detection
	services is optional for implementation of the Kerberos V5
	GSS-API mechanism.

For some reason RFC 4121, which appears to be the one describing the v2
tokens, doesn't have similar text that I can find.  I can't tell what
they think you're supposed to do with sequence numbers, if anything.

RPC's (hence gss tokens) can be processed out of order, so it's a little
unclear how the sequence numbers would be checked.  You'd have to choose
a window of sequence numbers to track, I guess, and just reject anything
older.  Absence any guidance about how to do this in the RFC's this
sounds like a potential source of interoperability problems.

RPCSEC_GSS also has its own sequence number that's included in all the
data we encrypt or checksum, so should provide sufficient replay
protection on its own.  And the RPCSEC_GSS RPC's do tell you how to
determine the window and handle old tokens.

So I may be missing something--more review always welcomed--but I think
it's all OK.

Unless someone else has more to add I'll cook up a patch that attempts
to make the situation clearer to future unfortunate readers of this
code.

--b.
