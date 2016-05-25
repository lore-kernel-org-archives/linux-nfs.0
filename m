Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33068 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcEYQIw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 12:08:52 -0400
Received: by mail-oi0-f41.google.com with SMTP id k23so86185668oih.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 09:08:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160525072027.5107.qmail@ns.sciencehorizons.net>
References: <CA+55aFxPSW+84KfQ1N_WmND-wtvgj2zQm8nFPkRcc+gyU=uing@mail.gmail.com>
	<20160525072027.5107.qmail@ns.sciencehorizons.net>
Date: Wed, 25 May 2016 09:08:51 -0700
Message-ID: <CAADWXX_F0jOjui1iHti1eC6tsD+cwMzZ0T_16e9nCzAK6raFxA@mail.gmail.com>
Subject: Re: [PATCH 00/10] String hash improvements
From: Linus Torvalds <torvalds@linux-foundation.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: lkml <linux-kernel@vger.kernel.org>, alistair.francis@xilinx.com,
        Bruce Fields <bfields@fieldses.org>, geert@linux-m68k.org,
        gerg@linux-m68k.org, jlayton@poochiereds.net,
        linux-m68k@vger.kernel.org, linux-nfs@vger.kernel.org,
        michal.simek@xilinx.com, Thomas Gleixner <tglx@linutronix.de>,
        uclinux-h8-devel@lists.sourceforge.jp, ysato@users.sourceforge.jp
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 25, 2016 at 12:20 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
>
> Well, they're close, and I can and did *get* them ready.

Ok, thanks. For some odd reason all your emails in this series got
marked as spam. Every single one, including the cover letter (but not
your replies to the replies to this).

Stupidly, I unmarked them before thinking to ask google *why* they got
marked as spam.

Did you do something different to send this series than you usually do?

Would you mind sending it again (maybe you have changes due to some o
the comments, but even if not, I'd like to see what the spam filter
says)? You could do it just to me to avoid filling up the mailing list
with duplicates.

                    Linus
