Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51419 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241Ab0HGLEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Aug 2010 07:04:40 -0400
Date: Sat, 7 Aug 2010 21:04:22 +1000
From: Neil Brown <neilb@suse.de>
To: Jeff Layton <jlayton@samba.org>
Cc: Steve French <smfrench@gmail.com>, Jeremy Allison <jra@samba.org>,
        utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100807210422.0b8ce265@notabene>
In-Reply-To: <20100807063400.6bd1776f@tlielax.poochiereds.net>
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
	<AANLkTinVCLVpqLtA2X=1mOkxX7Re61_ZYsUix_XTvZ5D@mail.gmail.com>
	<20100807093057.7683bedd@notabene>
	<AANLkTikDBg5Brt=55Tsu8ozk0aVx=srpxP=U-sFqeBYL@mail.gmail.com>
	<20100807102901.6a0b53e7@notabene>
	<AANLkTinEFFAWMu62j2sCPy=ArExZNm2miJOGoXbG65jC@mail.gmail.com>
	<AANLkTik7KhgF=pkpdEcsYM75NVXNmU4ynzdh3KWknTEL@mail.gmail.com>
	<20100807133240.02883b83@notabene>
	<20100807063400.6bd1776f@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 7 Aug 2010 06:34:00 -0400
Jeff Layton <jlayton@samba.org> wrote:

> On Sat, 7 Aug 2010 13:32:40 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > So we are left with an attribute that is needed for windows compatibility,
> > and so just needs to be understood by samba and wine.  Some filesystems might
> > support it efficiently, others might require the use of generic
> > extended-attributes, still others might not support it at all (I guess you
> > store it in some 'tdb' and hope it works well enough).
> > 
> > Core-linux doesn't really need to know about this - there just needs to be a
> > channel to pass it between samba/wine and the filesystem. xattr still seems
> > the best mechanism to pass this stuff around.  Team-samba can negotiate with
> > fs developers to optimise/accelerate certain attributes, and linux-VFS
> > doesn't need to know or care (except maybe to provide generic non-blocking or
> > multiple-access interfaces).
> > 
> 
> IIUC, you're saying that we should basically just have samba stuff the
> current time into an xattr when it creates the file and leave the
> filesystems alone. If so, I disagree here.

I'm not quite saying that (though there is a temptation).  Some attributes
are initialised by the filesystem rather than by common code.  i_uid is a
simple example.  I have no problem with the filesystem initialising the
storage that is used for this well-known-EA to the current time at creation.
This would be part of what team-samba negotiated with FS developers.

> 
> The problem with treating this as *just* an xattr is that it doesn't
> account for files that are created outside of samba but are then shared
> out by it.

If something is created in a different universe, then brought into this one -
when is its date of birth?  The moment of creation, or the moment of entry
into this universe?   If both universes have a common time line (altough
with a 10 year offset) then I guess the former, though I think it is a bit of
a philosophical point.... :-)

> 
> To handle this correctly, I believe it needs to be initialized by the
> kernel to the current time whenever an inode is created, even if samba
> doesn't create it. After that, it can be treated as just another xattr.
> 
Yes, I suspect that would be ideal, and trivial for the fs to implement (it
has to initialise it to something after all).

i.e. I agree.

NeilBrown
