Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56124 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752416Ab1FQA0p convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2011 20:26:45 -0400
In-Reply-To: <20110616235600.14345.16839.stgit@warthog.procyon.org.uk>
References: <20110616235600.14345.16839.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Jun 2011 17:26:21 -0700
Message-ID: <BANLkTimxJ5kHOODSPqRPcgbObjZbfT59uw@mail.gmail.com>
Subject: Re: [PATCH] KEYS/DNS: Fix ____call_usermodehelper() to not lose the
 session keyring
To: David Howells <dhowells@redhat.com>
Cc: akpm@linux-foundation.org, jmorris@namei.org, shirishpargaonkar@gmail.com,
        keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Eric Paris <eparis@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 16, 2011 at 4:56 PM, David Howells <dhowells@redhat.com> wrote:
> ____call_usermodehelper() now erases any credentials set by the
> subprocess_inf::init() function.  The problem is that:

I absolutely puke looking at this patch.  It makes me want to dig out
my eyes with a spoon.

Yes, we had that nasty "umh" TLA before too, but it was mostly hidden
and private and kept a fairly low profile (ie only in that
wait-related enum). This makes it _truly_ barf-worthy by combining it
with a couple of new ugly function typedefs.

There really isn't any prize for the ugliest infrastructure ever.
Please just remove the pointless and ugly typedefs that are used in
just a couple of places. And in most of those cases it just makes the
code actually less readable (ie it's now totally impossible to see
what the type for the passed-in function pointers are, because it's
hidden behind that opaque type.

The only real reason to use typedefs in the kernel is if you really
have *different* types behind them, and explicitly want to make the
type more opaque. Yeah, we've occasionally broken that rule, but it's
almost always been a mistake when we do.

                                 Linus

PS. Possibly it might make more sense to just put the "struct cred *"
pointer into the "struct subprocess_info" and not change any of the
function prototypes at all?
