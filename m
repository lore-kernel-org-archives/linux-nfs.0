Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63149 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194Ab2I1CEy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 22:04:54 -0400
MIME-Version: 1.0
In-Reply-To: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 27 Sep 2012 19:04:32 -0700
Message-ID: <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
To: Alexander Graf <agraf@suse.de>
Cc: LKML List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        skinsbursky@parallels.com, bfields@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 27, 2012 at 6:55 PM, Alexander Graf <agraf@suse.de> wrote:
>
> Below are OOPS excerpts from different rc's I tried. All of them crashed - all the way up to current Linus' master branch. I haven't cross-checked, but I don't remember any such behavior from pre-3.6 releases.

Since you seem to be able to reproduce it easily (and apparently
reliably), any chance you could just bisect it?

Since I assume v3.5 is fine, and apparently -rc1 is already busted, a simple

   git bisect start
   git bisect good v3.5
   git bisect bad v3.6-rc1

will get you started on your adventure..

          Linus
