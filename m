Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:49073 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab0HGKeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Aug 2010 06:34:07 -0400
Date: Sat, 7 Aug 2010 06:34:00 -0400
From: Jeff Layton <jlayton@samba.org>
To: Neil Brown <neilb@suse.de>
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
Message-ID: <20100807063400.6bd1776f@tlielax.poochiereds.net>
In-Reply-To: <20100807133240.02883b83@notabene>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 7 Aug 2010 13:32:40 +1000
Neil Brown <neilb@suse.de> wrote:

> So we are left with an attribute that is needed for windows compatibility,
> and so just needs to be understood by samba and wine.  Some filesystems might
> support it efficiently, others might require the use of generic
> extended-attributes, still others might not support it at all (I guess you
> store it in some 'tdb' and hope it works well enough).
> 
> Core-linux doesn't really need to know about this - there just needs to be a
> channel to pass it between samba/wine and the filesystem. xattr still seems
> the best mechanism to pass this stuff around.  Team-samba can negotiate with
> fs developers to optimise/accelerate certain attributes, and linux-VFS
> doesn't need to know or care (except maybe to provide generic non-blocking or
> multiple-access interfaces).
> 

IIUC, you're saying that we should basically just have samba stuff the
current time into an xattr when it creates the file and leave the
filesystems alone. If so, I disagree here.

The problem with treating this as *just* an xattr is that it doesn't
account for files that are created outside of samba but are then shared
out by it.

To handle this correctly, I believe it needs to be initialized by the
kernel to the current time whenever an inode is created, even if samba
doesn't create it. After that, it can be treated as just another xattr.

-- 
Jeff Layton <jlayton@samba.org>
