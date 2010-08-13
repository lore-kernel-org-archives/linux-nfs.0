Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36658 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab0HMSJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:09:38 -0400
In-Reply-To: <20100813175410.GA8202@samba1>
References: <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	<1280524978.2452.9.camel@segv.aura.of.mankind>
	<20100801092529.5e6ba0e0@corrin.poochiereds.net>
	<20100805235218.GB31233@jeremy-laptop>
	<20100806133836.49757af9@notabene>
	<20100808121208.GA7329@jeremy-laptop>
	<20100808085301.24f53e5a@tlielax.poochiereds.net>
	<20100808130501.GA9851@jeremy-laptop>
	<20100813125432.GB8945@fieldses.org>
	<20100813175410.GA8202@samba1>
Date: Fri, 13 Aug 2010 13:09:36 -0500
Message-ID: <AANLkTik3dBUgDEww8E+3T=bvKh7a5j82tBKStjVM73p3@mail.gmail.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
From: Steve French <smfrench@gmail.com>
To: Jeremy Allison <jra@samba.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Neil Brown <neilb@suse.de>, utz lehmann <lkml123@s2y4n2c.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Volker.Lendecke@sernet.de, David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsde@jasper.es
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 12:54 PM, Jeremy Allison <jra@samba.org> wrote:
> On Fri, Aug 13, 2010 at 08:54:32AM -0400, J. Bruce Fields wrote:
>> On Sun, Aug 08, 2010 at 06:05:01AM -0700, Jeremy Allison wrote:
>> > We don't need to ape Windows in everything.
>> > The coming ACL disaster will show that (we will go from an ACL
>> > model that is slightly too complex to use, to one that is impossibly
>> > complex to use :-).
>>
>> Care to elaborate?
>
> POSIX ACLs -> RichACLs (NT-style). Not criticising Andreas here,
> people are asking for this. But Windows ACLs are a nightmare
> beyond human comprehension :-). In the "too complex to be
> usable" camp.

Not much choice - even community colleges now have
to teach students about this ACL model in their sysadmin courses.

>> And what would native ACL support mean for Samba?
>
> RichACLs'll do it, but I feel sorry for the admins :-).

Yes - RichACLs and Windows ACLs allow you to set
some strange combinations of permssion bits.
RichACLs will make a more natural mapping for
Samba and NFSv4 - and it is far too late to
remove the requirement for Windows and
MacOS (among other clients) support.



-- 
Thanks,

Steve
