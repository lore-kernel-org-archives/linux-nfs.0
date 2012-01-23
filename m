Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:48851 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab2AWWXw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 17:23:52 -0500
Received: by werb13 with SMTP id b13so2524829wer.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 14:23:50 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20120123211247.GA1452@fieldses.org>
References: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
	<20120123211247.GA1452@fieldses.org>
Date: Mon, 23 Jan 2012 23:23:50 +0100
Message-ID: <CAGue13pu8=sSrf71KxgkP-GhpM4nv0yF5LfGr29T_Lp4Oj27cw@mail.gmail.com>
Subject: Re: [PATH v7 00/10] handle curruent stateid
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2012 at 10:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sun, Jan 22, 2012 at 07:45:59PM +0100, Tigran Mkrtchyan wrote:
>> From: Tigran Mkrtchyan <kofemann@gmail.com>
>>
>> The same as v6, expect that the last patch changes current_stateid
>> in compoind from reference to a value. As patches have to be squashed
>> anyway
>
> Why?

for me none of them makes sense alone. But, of course, you have your own rules.

>
> If it's really only possible as a single big patch I'd actually rather
> have it submitted that way....
>
>> this aproach is simple that re-write all.
>
> Fine, but #10 doesn't seem to have made it to my mailbox or to the list?

Ha! turned out that 000*.patch does not include 0010-X.patch :-D

Tigran.

>
> --b.
>
>>
>> This is ready-to-go patch set. Rebased to Bruce's nfsd-next.
>>
>> Implemented for:
>>
>>  OPEN
>>  OPENDOWNGRADE
>>  CLOSE
>>  LOCK
>>  LOCKU
>>  DELEGRETURN
>>  FREE_STATEID
>>  SETATTR
>>  READ
>>  WRITE
>>  SAVEFH
>>  RESTOREFH
>>  PUTFH
>>  PUTROOTFH
>>  PUTPUBFH
>>  LOOKUP
>>  CREATE
>>
>>
>> Coresponding pynfs test already submited.
>>
>> Tigran.
>>
>> Tigran Mkrtchyan (10):
>>   nfsd4: initialize current stateid at compile time
>>   nfsd41: handle current stateid in open and close
>>   nfsd41: handle current stateid on lock and locku
>>   nfsd41: consume current stateid on read and write
>>   nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
>>   nfsd41: save and restore current stateid with current fh
>>   nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
>>   nfsd41: handle current stateid in SETATTR and FREE_STATEID
>>   nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
>>   nfsd41: use current stateid by value
>>
>>  fs/nfsd/current_stateid.h |   28 +++++++++++
>>  fs/nfsd/nfs4proc.c        |   61 +++++++++++++++++++++----
>>  fs/nfsd/nfs4state.c       |  110 ++++++++++++++++++++++++++++++++++++++++++++-
>>  fs/nfsd/xdr4.h            |    4 ++
>>  4 files changed, 192 insertions(+), 11 deletions(-)
>>  create mode 100644 fs/nfsd/current_stateid.h
>>
>> --
>> 1.7.7.5
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
