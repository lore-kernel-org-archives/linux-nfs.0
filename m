Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:38119 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab0HHMML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Aug 2010 08:12:11 -0400
Date: Sun, 8 Aug 2010 05:12:09 -0700
From: Jeremy Allison <jra@samba.org>
To: Neil Brown <neilb@suse.de>
Cc: Jeremy Allison <jra@samba.org>, Jeff Layton <jlayton@redhat.com>,
        utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100808121208.GA7329@jeremy-laptop>
Reply-To: Jeremy Allison <jra@samba.org>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
 <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <1280524978.2452.9.camel@segv.aura.of.mankind>
 <20100801092529.5e6ba0e0@corrin.poochiereds.net>
 <20100805235218.GB31233@jeremy-laptop>
 <20100806133836.49757af9@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100806133836.49757af9@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 06, 2010 at 01:38:36PM +1000, Neil Brown wrote:
> I'm curious.  Why do you particularly care what interface the kernel uses to
> provide you with access to this attribute?

It's a matter of taste. The *BSD's have this right IMHO. It
should be part of the stat information. A file timestamp is not
an EA. Making it available that way just feels like an appalingly
tasteless kludge. It offends the artist in me :-).

> Or do you really want something like BSD's 'btime' which as I understand it
> cannot be set.  Would that be really useful to you?

It is *already* useful to us, and is widely used in
existing code. The occasions when btime is set are
relatively rare, and at that point we store it in a
separate EA for Windows reporting purposes.

Jeremy.
