From: Nicolas Williams <Nicolas.Williams-xsfywfwIY+M@public.gmane.org>
Subject: Re: [nfs-discuss] mount.nfs: access denied by server
Date: Wed, 26 Aug 2009 16:03:48 -0500
Message-ID: <20090826210348.GJ1033@Sun.COM>
References: <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com> <1251219492.25372.3.camel@heimdal.trondhjem.org> <4A942ACF.4030502@sun.com> <1251225543.25372.22.camel@heimdal.trondhjem.org> <1251225797.25372.25.camel@heimdal.trondhjem.org> <4A9462E4.5020404@sun.com> <1251242416.5403.3.camel@heimdal.trondhjem.org> <20090825233758.GZ1033@Sun.COM> <1251246105.5403.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sca-ea-mail-4.Sun.COM ([192.18.43.22]:39079 "EHLO
	sca-ea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbZHZVq0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 17:46:26 -0400
Received: from dm-central-01.central.sun.com ([129.147.62.4])
	by sca-ea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7QLTdGE008068
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2009 21:29:39 GMT
Received: from binky.Central.Sun.COM (binky.Central.Sun.COM [129.153.128.104])
	by dm-central-01.central.sun.com (8.13.8+Sun/8.13.8/ENSMAIL,v2.2) with ESMTP id n7QLTckW023205
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2009 15:29:39 -0600 (MDT)
In-Reply-To: <1251246105.5403.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2009 at 08:21:45PM -0400, Trond Myklebust wrote:
> On Tue, 2009-08-25 at 18:37 -0500, Nicolas Williams wrote:
> > Looking at code we have
> > ...
> 
> Sorry. I didn't mean to force you into detailed explanations of the
> code. As a NetApp employee, I'm not sure I'm licensed to even run
> OpenSolaris at this point, let alone look at the code. :-)

Well, you don't need a license to look at it (though you might need
permission from your employer, and they may not grant it), and I can't
imagine that my mentioning a few function names could taint you in any
way.  Nor would I normally keep from mentioning actual OpenSolaris code
on OpenSolaris discuss lists.  If it helps generic protocol discussions
I'm willing to refrain from further discussing code in any one thread
once you ask that I do, but I'd much rather such discussions take place
in the IETF NFSv4 WG mailing list instead then (where I would generally
refrain from posting code).

> > Which means that WRONGSEC -> SECINFO -> updates the entire mount's sec.
> 
> OK. This is sort of what I expect we will do for Linux too.

OK.

> The protocol will even allow you to set the secinfo on a per-file basis.

True.

> That sounds insane to me, but...

NFS clients typically allow you to mount individual files, not just
directories.

There's no "MOUNT" operation in the protocol.  Mounts have traditionally
been entirely a client-side concept.  NFSv4 exposes server-side
hierarchical filesystem mount structures to the clients, but there's
still no MOUNT operation, and clients needn't even have a notion of
"mount" (POSIX clients may have to, but others may not).

Clients could even treat every FH as needing a "mount" (meaning df(1),
mount(1M), nfsstat(1M), etcetera may list every single file and
directory recently accessed as mounts).

OpenSolaris could react to a WRONGSEC by instantiating a mount
dynamically where there really shouldn't be one.  It may even have to,
so that sec= settings may be reported to users through existing
interfaces (unless we don't care for that).  The same might apply to
Linux.  This sort of complexity argues that SECINFO should be
per-filesystem, but see below.

> Anyhow, I think our Linux client should go with the 'remove security
> flavours only on mountpoints' rule for now, and then we'll see in time
> if any users can justify a more fine grained implementation.

BTW, the same considerations apply to sub-shares with other option
differences.

For example (note: I've not tested this):

server% mount /foo
server% share -F nfs -o rw /foo
server% mkdir /foo/bar
server% mkdir /foo/ick
server% share -F nfs -o ro /foo

client% mount server:/foo /foo
client% touch /foo/ick/a
client% touch /foo/bar/a
touch: cannot create /foo/bar/a: Read-only file system
client% touch /foo/ick/b
touch: cannot create /foo/bar/a: Read-only file system

We ought either say that clients MUST cope with hierarchical shares
within a single filesystem, or that hierarchical shares within a
filesystem MUST NOT be allowed.  I'm not sure that I'd be ready to say
the latter, while on the other hand the complexity of the former is
certainly a challenge.

Nico
-- 
