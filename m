Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37797 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab3KYKFk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 05:05:40 -0500
MIME-Version: 1.0
In-Reply-To: <19201.1385372189@warthog.procyon.org.uk>
References: <CAMuHMdUiK4CHXESCEYvGJfE1ROGa=MC_c=qAQgKVS7GmkBXz=Q@mail.gmail.com>
	<19201.1385372189@warthog.procyon.org.uk>
Date: Mon, 25 Nov 2013 11:05:39 +0100
Message-ID: <CAMuHMdWNKJP6wA0AGvEN1dEKNw9Vux+5sSv=6An8M-TdBCCGZA@mail.gmail.com>
Subject: Re: assoc_array.c uninitialized variable (was: Re: [PATCH 02/10] Add
 a generic associative array implementation.)
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-security-module@vger.kernel.org,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Mon, Nov 25, 2013 at 10:36 AM, David Howells <dhowells@redhat.com> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
>> > +       int slot, next_slot, free_slot, i, j;
>>
>> lib/assoc_array.c: In function ‘assoc_array_insert_into_terminal_node’:
>> lib/assoc_array.c:502: warning: ‘j’ may be used uninitialized in this function
>
> What compiler are you using?  Mine doesn't show this.

Good old 4.2.1. Newer compilers don't give these warnings anymore, presumably
because there were too many false positives. But from time to time, there's
a real issue.

> Technically, the compiler is correct - but we should never see the variable
> undefined following the found_slot_for_multiple_occupancy unless the tree
> changes under us. Out of a set of N+1 integers that can only be in the range
> 0..N-1 there must be at least two the same.

OK.

> I guess I could preclear j to make the warning go away.

Please use a big number instead of zero, so the

        BUG_ON(j >= ASSOC_ARRAY_FAN_OUT + 1);

will catch it later.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
