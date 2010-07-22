Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Mycroft.westnet.com ([216.187.52.7]:36312 "EHLO
	mycroft.westnet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab0GVToN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 15:44:13 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19528.39283.469638.12844@stoffel.org>
Date: Thu, 22 Jul 2010 15:18:11 -0400
From: "John Stoffel" <john@stoffel.org>
To: Jeremy Allison <jra@samba.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
In-Reply-To: <20100722180204.GA32008@samba1>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1279817930.3621.14.camel@heimdal.trondhjem.org>
	<20100722180204.GA32008@samba1>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>>>>> "Jeremy" == Jeremy Allison <jra@samba.org> writes:

Jeremy> On Thu, Jul 22, 2010 at 12:58:50PM -0400, Trond Myklebust wrote:
>> 
>> That would make it impossible to export the filesystem with NFSv2 and
>> v3. They do rely on ctime checking for certain operations (e.g. deciding
>> when to invalidate access and acl caches). NFSv4 needs this too if the
>> filesystem has no dedicated change attribute.
>> 
>> Still, I suppose the market for exporting the same filesystem with both
>> NFS and Samba is limited...

Jeremy> Ask NetApp about that :-). They have built a rather large
Jeremy> business on just that fact :-).

And it does work, as long as you also go with either unix or windows
semantics for the security and permissions bits.  If you try to use
the mixed-mode, you're in for a world of hurt.

Oh yeah, Netapp still uses dump/restore for it's backups.  :]  Though
whether it's still dependent on the optimization of ctime being used
to know whether to just dump the inode only or not, I can't say.

John
