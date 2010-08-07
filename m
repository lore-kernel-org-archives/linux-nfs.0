Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42884 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168Ab0HGDdA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 23:33:00 -0400
Date: Sat, 7 Aug 2010 13:32:40 +1000
From: Neil Brown <neilb@suse.de>
To: Steve French <smfrench@gmail.com>
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
Message-ID: <20100807133240.02883b83@notabene>
In-Reply-To: <AANLkTik7KhgF=pkpdEcsYM75NVXNmU4ynzdh3KWknTEL@mail.gmail.com>
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
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 6 Aug 2010 21:54:49 -0500
Steve French <smfrench@gmail.com> wrote:

> On Fri, Aug 6, 2010 at 9:42 PM, Steve French <smfrench@gmail.com> wrote:
> > On Fri, Aug 6, 2010 at 7:29 PM, Neil Brown <neilb@suse.de> wrote:
> >> On Fri, 6 Aug 2010 18:58:42 -0500
> >> Steve French <smfrench@gmail.com> wrote:
> >>
> >>> On Fri, Aug 6, 2010 at 6:30 PM, Neil Brown <neilb@suse.de> wrote:
> >>> > On Thu, 5 Aug 2010 22:55:06 -0500
> >>> > Steve French <smfrench@gmail.com> wrote:
> >>> >
> >>> >> On Thu, Aug 5, 2010 at 10:38 PM, Neil Brown <neilb@suse.de> wrote:
> >>> >> > On Thu, 5 Aug 2010 16:52:18 -0700
> >>> >> > Jeremy Allison <jra@samba.org> wrote:
> >>> >>
> >>> >> >> Don't add it as an EA. It's *not* an EA, it's a timestamp.
> >>> >> >
> >>> >> > I'm curious.  Why do you particularly care what interface the kernel uses to
> >>> >> > provide you with access to this attribute?
> >>> >> >
> >>> >> > And given that it is an attribute that is not part of 'POSIX' or "UNIX", it
> >>> >> > would seem to be an extension - an extended attribute.
> >>> >> > As the Linux kernel does virtually nothing with this attribute except provide
> >>> >> > access, it seems to be a very different class of thing to other timestamps.
> >>> >> > Surely it is simply some storage associated with a file which is capable of
> >>> >> > storing a timestamp, which can be set or retrieved by an application, and
> >>> >> > which happens to be initialised to the current time when a file is created.
> >>> >> >
> >>> >> > Yes, to you it is a timestamp.  But to Linux it is a few bytes of
> >>> >> > user-settable metadata.  Sounds like an EA to me.
> >>> >> >
> >>> >> > Or do you really want something like BSD's 'btime' which as I understand it
> >>> >> > cannot be set.  Would that be really useful to you?
> >>> >>
> >>> >> Obviously the cifs and SMB2 protocols which  Samba server support can
> >>> >> ask the server to set the create time of a file (this is handled
> >>> >> through xattrs today along with the "dos attribute" flags such as
> >>> >> archive/hidden/system), but certainly it is much more common (and
> >>> >> important) to read the creation time of an existing file.
> >>> >>
> >>> >
> >>> > Just a point of clarification - when you say it is common and important to be
> >>> > able to read the creation time on an existing file, and you still talking in
> >>> > the context of cifs/smb windows compatibility, or are you talking in the
> >>> > broader context?
> >>> > If you are referring to a broader context could be please give more details
> >>> > because I have not heard any mention of any real value of creation-time out
> >>> > side of window interoperability - have such a use clearly documented would
> >>> > assist the conversation I think.
> >>> >
> >>> > If on the other hand you are just referring the the windows interoperability
> >>> > context ... given that you have to read an EA if the create-time has been
> >>> > changed, you will always have to read and EA so having something else is
> >>> > pointless ... or I'm missing something.
> >>>
> >>> There are other cases, less common than cifs and smb2.   One
> >>> that comes to mind is NFS version 4, but there are a few other
> >>> cases that I have heard of (backup/archive applications).
> >>> The RFC recommends that servers return attribute 50 (creation
> >>> time).  See below text:
> >>>
> >>>    time_create         50   nfstime4       R/W      The time of creation
> >>>                                                     of the object.  This
> >>>                                                     attribute does not
> >>>                                                     have any relation to
> >>>                                                     the traditional UNIX
> >>>                                                     file attribute
> >>>                                                     "ctime" or "change
> >>>                                                     time".
> >>
> >> I really don't think NFSv4 is a separate justification.  I'm fairly sure
> >> that attribute was only including in NFSv4 for enhanced Windows
> >> compatibility (windows interoperation was a big issue during the protocol
> >> development).
> >
> > Perhaps also useful for MacOS (and other BSD), not just Windows,
> > although MacOS may use cifs more often than nfs.
> 
> >> That leaves hypothetical "backup/archive applications".
> >> Do you have a concrete example?
> 
> A quick search for backup applications in Wikipedia came up with a
> reference fairly easily (to backup app which uses creation
> time) for Linux:
> 
> http://www.aqualab.cs.northwestern.edu/publications/Cornell04VFS.html

That publication seems to mention 'creation time' only as an abstract concept.
The backup architecture keeps a history of the file all that way back to its
"creation time".
It doesn't appear to need or use a 'creation time' attribute stored with any
file.

> 
> Presumably Windows compat. is a stronger motivation, than BSD/MacOS
> NFSv4 (returning birth time) compat, and backup applications
> are a lesser motivations.   There may also be some value in using creation
> time as a generation number where no generation number is
> available.
> 
> Intuitively seems like creation time would be as "useful" as ctime (and probably
> more so) to app developers ... but that is hard to prove.
> 

I agree, it does seem like an intuitively valuable number - after all we each
have a birthday which we are very aware of and often make use of.  It is
often treated as part of our identity - just like you were mentioning that
the CIFS client uses creation-time to help identify files which lack the
'inode number' identifier that is the common tool in Unix and derivatives.

But I'm not convinced that it is *practically* useful.  The only practical
use beyond windows-compatibility that has been mentioned is a stronger
'identity' tag.  However inode+generation number, or "file-handle-fragment"
are better things to use for identifying a file than "creation time",
especially when the latter is settable.

So if we were to add something for native applications to use, I doubt that
it would be 'creation time' (but I'm still open to hearing a convincing
use-case).

So we are left with an attribute that is needed for windows compatibility,
and so just needs to be understood by samba and wine.  Some filesystems might
support it efficiently, others might require the use of generic
extended-attributes, still others might not support it at all (I guess you
store it in some 'tdb' and hope it works well enough).

Core-linux doesn't really need to know about this - there just needs to be a
channel to pass it between samba/wine and the filesystem. xattr still seems
the best mechanism to pass this stuff around.  Team-samba can negotiate with
fs developers to optimise/accelerate certain attributes, and linux-VFS
doesn't need to know or care (except maybe to provide generic non-blocking or
multiple-access interfaces).

What is 'creation time' used for in the windows world??? Maybe there really
is something valuable here that we are missing....

NeilBrown
