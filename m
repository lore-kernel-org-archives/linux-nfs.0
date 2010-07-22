Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:39277 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210Ab0GVQ1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 12:27:03 -0400
Date: Thu, 22 Jul 2010 09:27:12 -0700
From: Jeremy Allison <jra@samba.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100722162712.GB10352@jeremy-laptop>
Reply-To: Jeremy Allison <jra@samba.org>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 08:47:46AM -0700, Linus Torvalds wrote:
> On Thu, Jul 22, 2010 at 8:36 AM, Volker Lendecke
> <Volker.Lendecke@sernet.de> wrote:
> >
> > The nice thing about this is also that if this is supposed
> > to be fully usable for Windows clients, the birthtime needs
> > to be changeable. That's what NTFS semantics gives you, thus
> > Windows clients tend to require it.
> 
> Ok. So it's not really a creation date, exactly the same way ctime
> isn't at all a creation date.
> 
> And maybe that actually hints at a better solution: maybe a better
> model is to create a new per-thread flag that says "do ctime updates
> the way windows does them".
> 
> So instead of adding another "btime" - which isn't actually what even
> windows does - just admit that the _real_ issue is that Unix and
> Windows semantics are different for the pre-existing "ctime".
> 
> The fact is, windows has "access time", "modification time" and
> "creation time" _exactly_ like UNIX. It's just that the ctime has
> slightly different semantics in windows vs unix. So quite frankly,
> it's totally insane to introduce a "birthtime", when that isn't even
> what windows wants, just because people cannot face the actual real
> difference.
> 
> Tell me why we shouldn't just do this right?

No, ctime isn't the same as Windows "create time". Windows
"create time" semantics are that the timestamp is set to
current time on file creation, but afterwards anyone with
sufficient access can then modify it (!). Which is different
from the "birthtime" spec on *BSD, as they can't be modified.

Currently on *BSD we look for our special EA containing any
modified create times on a file, and return that as "create
time" if found, if not we return the st_birthtime from the
stat struct. That works well enough for systems where you
don't want to allow birthtime to be changed. Having said
that I'm not sure how they cope with doing restores to
a filesystem where you would need to set st_birthtime :-).

Jeremy.
