Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f191.google.com ([209.85.210.191]:41407 "EHLO
	mail-yx0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab0CIPWQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 10:22:16 -0500
Received: by yxe29 with SMTP id 29so986110yxe.4
        for <linux-nfs@vger.kernel.org>; Tue, 09 Mar 2010 07:22:15 -0800 (PST)
In-Reply-To: <20100309151053.GC21862@fieldses.org>
References: <20100309014624.GF2999@fieldses.org>
	 <ABA6EE88-3584-4DC9-A50B-3B0E06C701FB@netapp.com>
	 <20100309145354.GB21862@fieldses.org>
	 <89c397151003090655h7f3465f2u36c60cfa0b580516@mail.gmail.com>
	 <20100309151053.GC21862@fieldses.org>
Date: Tue, 9 Mar 2010 10:17:04 -0500
Message-ID: <89c397151003090717v7b744eb7i8c1c941f169e45e2@mail.gmail.com>
Subject: Re: reboot recovery
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 9, 2010 at 10:10 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Mar 09, 2010 at 09:55:52AM -0500, William A. (Andy) Adamson wrote:
>> On Tue, Mar 9, 2010 at 9:53 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Tue, Mar 09, 2010 at 09:46:04AM -0500, Andy Adamson wrote:
>> >>
>> >> RFC 5661 in section 18.51.3
>> >>
>> >>    Whenever a client establishes a new client ID and before it does the
>> >>    first non-reclaim operation that obtains a lock, it MUST send a
>> >>    RECLAIM_COMPLETE with rca_one_fs set to FALSE, even if there are no
>> >>    locks to reclaim.  If non-reclaim locking operations are done before
>> >>    the RECLAIM_COMPLETE, an NFS4ERR_GRACE error will be returned.
>> >>
>> >> So there will never be a 'first OPEN' (except for an OPEN reclaim)
>> >> without a RECLAIM_COMPLETE.
>> >
>> > There will be in the case of an entirely new client, or a client that
>> > missed the grace period completely.
>>
>> No, the MUST above applies to both a new client/client that missed the
>> grace period completely. In both cases the client is establishing a
>> new client ID.
>
> Oog, sorry, obviously I can't read--I see what you mean now.
>
> I haven't seen any client send a RECLAIM_COMPLETE or any server demand
> one yet, so do we all have this wrong?

The latest Linux client does send a RECLAIM_COMPLETE after each
EXCHANGE_ID. This change was part of the 'A' tasks for NFSv4.1.

-->Andy

>
> Or was the above a mistake and they meant to say something like
> "whenever a client *that previously held state* establishes a new client
> ID...."?
>
> --b.
>
