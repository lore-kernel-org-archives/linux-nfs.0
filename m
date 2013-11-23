Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35085 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab3KWMJv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Nov 2013 07:09:51 -0500
MIME-Version: 1.0
Date: Sat, 23 Nov 2013 13:09:51 +0100
Message-ID: <CAMuHMdUiK4CHXESCEYvGJfE1ROGa=MC_c=qAQgKVS7GmkBXz=Q@mail.gmail.com>
Subject: assoc_array.c uninitialized variable (was: Re: [PATCH 02/10] Add a
 generic associative array implementation.)
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-security-module@vger.kernel.org,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 17, 2013 at 10:43 PM, David Howells <dhowells@redhat.com> wrote:
> +/*
> + * Handle insertion into a terminal node.
> + */
> +static bool assoc_array_insert_into_terminal_node(struct assoc_array_edit *edit,
> +                                                 const struct assoc_array_ops *ops,
> +                                                 const void *index_key,
> +                                                 struct assoc_array_walk_result *result)
> +{
> +       struct assoc_array_shortcut *shortcut, *new_s0;
> +       struct assoc_array_node *node, *new_n0, *new_n1, *side;
> +       struct assoc_array_ptr *ptr;
> +       unsigned long dissimilarity, base_seg, blank;
> +       size_t keylen;
> +       bool have_meta;
> +       int level, diff;
> +       int slot, next_slot, free_slot, i, j;

lib/assoc_array.c: In function ‘assoc_array_insert_into_terminal_node’:
lib/assoc_array.c:502: warning: ‘j’ may be used uninitialized in this function

> +       /* Begin by finding two matching leaves.  There have to be at least two
> +        * that match - even if there are meta pointers - because any leaf that
> +        * would match a slot with a meta pointer in it must be somewhere
> +        * behind that meta pointer and cannot be here.  Further, given N
> +        * remaining leaf slots, we now have N+1 leaves to go in them.
> +        */
> +       for (i = 0; i < ASSOC_ARRAY_FAN_OUT; i++) {
> +               slot = edit->segment_cache[i];
> +               if (slot != 0xff)
> +                       for (j = i + 1; j < ASSOC_ARRAY_FAN_OUT + 1; j++)

j is initialized here, but only if slot != 0xff.

The comment above states "there have to be at least two that match",
so this may be a false positive, but better safe than sorry.

> +                               if (edit->segment_cache[j] == slot)
> +                                       goto found_slot_for_multiple_occupancy;
> +       }
> +found_slot_for_multiple_occupancy:
> +       pr_devel("same slot: %x %x [%02x]\n", i, j, slot);
> +       BUG_ON(i >= ASSOC_ARRAY_FAN_OUT);
> +       BUG_ON(j >= ASSOC_ARRAY_FAN_OUT + 1);
> +       BUG_ON(slot >= ASSOC_ARRAY_FAN_OUT);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
