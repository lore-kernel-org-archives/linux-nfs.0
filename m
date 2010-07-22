Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56181 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751555Ab0GVPsQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 11:48:16 -0400
In-Reply-To: <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Jul 2010 08:47:46 -0700
Message-ID: <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
To: Volker.Lendecke@sernet.de
Cc: David Howells <dhowells@redhat.com>, Jan Engelhardt <jengelh@medozas.de>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 8:36 AM, Volker Lendecke
<Volker.Lendecke@sernet.de> wrote:
>
> The nice thing about this is also that if this is supposed
> to be fully usable for Windows clients, the birthtime needs
> to be changeable. That's what NTFS semantics gives you, thus
> Windows clients tend to require it.

Ok. So it's not really a creation date, exactly the same way ctime
isn't at all a creation date.

And maybe that actually hints at a better solution: maybe a better
model is to create a new per-thread flag that says "do ctime updates
the way windows does them".

So instead of adding another "btime" - which isn't actually what even
windows does - just admit that the _real_ issue is that Unix and
Windows semantics are different for the pre-existing "ctime".

The fact is, windows has "access time", "modification time" and
"creation time" _exactly_ like UNIX. It's just that the ctime has
slightly different semantics in windows vs unix. So quite frankly,
it's totally insane to introduce a "birthtime", when that isn't even
what windows wants, just because people cannot face the actual real
difference.

Tell me why we shouldn't just do this right?

                Linus
