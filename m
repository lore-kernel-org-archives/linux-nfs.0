Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37444 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751185AbdIPNLW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Sep 2017 09:11:22 -0400
Cc: mtk.manpages@gmail.com, Ian Kent <ikent@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH manpages] stat.2: correct AT_NO_AUTOMOUNT text and general
 revisions.
To: NeilBrown <neilb@suse.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
 <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com>
 <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com>
 <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com>
 <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name>
 <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
 <87h8x1l9qp.fsf@notabene.neil.brown.name>
 <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
 <87r2w3jdn5.fsf@notabene.neil.brown.name>
 <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
 <87inhdk3rq.fsf@notabene.neil.brown.name>
 <CAKgNAki1SYjr7-6g-i3shGjQRjwy81gS0QisfZRy-x-bHFtXmA@mail.gmail.com>
 <87valci55j.fsf@notabene.neil.brown.name>
 <CAKgNAkinKkG8cR1ng0V3K1D9QNQ9MSeNkPpvpeGSUd5RqFiwSw@mail.gmail.com>
 <87r2v89auk.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <e554a428-5a6f-164a-4e9c-17dbef8ddfe7@gmail.com>
Date: Sat, 16 Sep 2017 15:11:16 +0200
MIME-Version: 1.0
In-Reply-To: <87r2v89auk.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/15/2017 12:25 AM, NeilBrown wrote:
> On Thu, Sep 14 2017, Michael Kerrisk (man-pages) wrote:
> 
>> Hi Neil,
>>
>> On 25 August 2017 at 07:32, NeilBrown <neilb@suse.com> wrote:
>>>
>>> Expand on the relationship between fstatat() and the other
>>> three functions, and improve the description of AT_NO_AUTOMOUNT.
>>> Specifically, both  stat() and lstat() act the same way
>>> with respect to automounts, and that behavior matches
>>> fstatat with the AT_NO_AUTOMOUNT flag.
>>>
>>> The text in the NOTES is removed and places with the text for
>>> AT_NO_AUTOMOUNT to improve cohesion.
>>>
>>> New text for a difference to be introduced in 4.14.
>>
>> Has the 4.14 piece gone in?
>>
> 
> Yes.
> 
> Commit: 42f461482178 ("autofs: fix AT_NO_AUTOMOUNT not being honored")

Thanks. I've applied the patch.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
