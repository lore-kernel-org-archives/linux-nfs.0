Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55337 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460Ab0HMTGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 15:06:32 -0400
Date: Fri, 13 Aug 2010 21:06:28 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Jeremy Allison <jra@samba.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Neil Brown <neilb@suse.de>, utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, linux-fsde@jasper.es
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
  file stats available [ver #6]
In-Reply-To: <20100813175410.GA8202@samba1>
Message-ID: <alpine.LSU.2.01.1008132104290.12206@obet.zrqbmnf.qr>
References: <E1Obuiy-00C9jr-Al@intern.SerNet.DE> <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com> <1280524978.2452.9.camel@segv.aura.of.mankind> <20100801092529.5e6ba0e0@corrin.poochiereds.net> <20100805235218.GB31233@jeremy-laptop>
 <20100806133836.49757af9@notabene> <20100808121208.GA7329@jeremy-laptop> <20100808085301.24f53e5a@tlielax.poochiereds.net> <20100808130501.GA9851@jeremy-laptop> <20100813125432.GB8945@fieldses.org> <20100813175410.GA8202@samba1>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Friday 2010-08-13 19:54, Jeremy Allison wrote:
>On Fri, Aug 13, 2010 at 08:54:32AM -0400, J. Bruce Fields wrote:
>> On Sun, Aug 08, 2010 at 06:05:01AM -0700, Jeremy Allison wrote:
>> > We don't need to ape Windows in everything.
>> > The coming ACL disaster will show that (we will go from an ACL
>> > model that is slightly too complex to use, to one that is impossibly
>> > complex to use :-).
>> 
>> Care to elaborate?
>
>POSIX ACLs -> RichACLs (NT-style). Not criticising Andreas here,
>people are asking for this. But Windows ACLs are a nightmare
>beyond human comprehension :-). In the "too complex to be
>usable" camp.

Well, for one, ACLs in NT can be recursive IIRC. You can't say that of Linux
ACLs - instead you have to setfacl -R and setfacl -Rd to give one user access
to a directory and all its subdirs including future new inodes.
