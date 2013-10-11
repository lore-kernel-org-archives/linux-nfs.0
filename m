Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984Ab3JKWvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Oct 2013 18:51:52 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20131011151402.33dfe46e@tlielax.poochiereds.net>
References: <20131011151402.33dfe46e@tlielax.poochiereds.net> <20131011161659.15534.27955.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, jmorris@namei.org, Scott Mayhew <smayhew@redhat.com>,
        keyrings@linux-nfs.org, Dave Wysochanski <dwysocha@redhat.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org
Subject: Re: [PATCH] KEYS: Fix a race between negating a key and reading the error set
Date: Fri, 11 Oct 2013 23:51:46 +0100
Message-ID: <7165.1381531906@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> > -		if (kflags & (1 << KEY_FLAG_NEGATIVE))
> > +		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
> 
> Not specifically related to this bug, but why are you open-coding
> test_bit() here and elsewhere?

Because kflags is read once and kept in a variable.  Might not be necessary -
and I should probably use ACCESS_ONCE() when I do.

David
