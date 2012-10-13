Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:49650 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751727Ab2JMCnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:43:13 -0400
Date: Fri, 12 Oct 2012 19:43:12 -0700
From: Larry McVoy <lm@bitmover.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121013024312.GK23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <5078D17C.9090002@panasas.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com>
 <5078D45A.3090801@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5078D45A.3090801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I could go in on a weekend and bang on things if that helps.  Here's some
other info:  we use old systems so we are forward compat.  The mac was
/ is running MacOS 10.4:

macos-x86:~ uname -a
Darwin macos-x86.bitmover.com 8.11.1 Darwin Kernel Version 8.11.1: Wed Oct 10
18:23:28 PDT 2007; root:xnu-792.25.20~1/RELEASE_I386 i386 i386

No idea if they fucked up NFS, certainly possible.

The way to make it happen is to have your home directory mounted on that
machine and fire up skype.  It tries to do some locking thing and barfs.

How do I figure out which NFS version macos is using?

macos-x86:~ mount
/dev/disk0s2 on / (local, journaled)
devfs on /dev (local)
fdesc on /dev (union)
<volfs> on /.vol
automount -nsl [144] on /Network (automounted)
automount -fstab [148] on /automount/Servers (automounted)
automount -static [148] on /automount/static (automounted)
10.3.9.1:/home on /private/var/automount/home (automounted)

On Fri, Oct 12, 2012 at 07:39:22PM -0700, Boaz Harrosh wrote:
> On 10/12/2012 07:32 PM, Myklebust, Trond wrote:
> > On Fri, 2012-10-12 at 19:27 -0700, Boaz Harrosh wrote:
> >> On 10/12/2012 04:52 PM, Linus Torvalds wrote:
> >>> Guys, check this report from Larry out.
> >>>
> >>> Also, why the *HELL* is that a BUG_ON() in the first place? Who was
> >>> the less-than-gifted person who decided "if this thing can happen,
> >>> let's just kill the whole machine"?
> >>>
> >>
> >> Something is trivially weird
> >>
> >> fs/lockd/clntxdr.c:226 is in this static function:
> >> 	encode_nlm_stat()
> >>
> >> encode_nlm_stat() is called in two places
> >> 	static void nlm_xdr_enc_res(...)
> >>   and
> >> 	static void nlm_xdr_enc_testres(...)
> >>
> >> But these two are not called anywhere. In-fact a Kernel wide grep
> >> returns a single occurrence of both
> > 
> > They are used in the nlm_procedures[] array as TEST_RES, LOCK_RES,
> > CANCEL_RES, UNLOCK_RES and GRANTED_RES xdr encoding procedures.
> > 
> 
> Ha, sorry that was impossible to find. OK I'll have a look
> 
> Thanks
> Boaz

-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
