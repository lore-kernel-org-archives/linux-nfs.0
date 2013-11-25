Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab3KYJgh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 04:36:37 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAMuHMdUiK4CHXESCEYvGJfE1ROGa=MC_c=qAQgKVS7GmkBXz=Q@mail.gmail.com>
References: <CAMuHMdUiK4CHXESCEYvGJfE1ROGa=MC_c=qAQgKVS7GmkBXz=Q@mail.gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: dhowells@redhat.com, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org,
        "open list\:NFS\, SUNRPC\, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: assoc_array.c uninitialized variable (was: Re: [PATCH 02/10] Add a generic associative array implementation.)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Mon, 25 Nov 2013 09:36:29 +0000
Message-ID: <19201.1385372189@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> > +       int slot, next_slot, free_slot, i, j;
> 
> lib/assoc_array.c: In function ‘assoc_array_insert_into_terminal_node’:
> lib/assoc_array.c:502: warning: ‘j’ may be used uninitialized in this function

What compiler are you using?  Mine doesn't show this.

Technically, the compiler is correct - but we should never see the variable
undefined following the found_slot_for_multiple_occupancy unless the tree
changes under us. Out of a set of N+1 integers that can only be in the range
0..N-1 there must be at least two the same.

I guess I could preclear j to make the warning go away.

David
