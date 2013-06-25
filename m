Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:61318 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab3FYOAU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 10:00:20 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so28592936ied.28
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 07:00:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130625134325.GA17511@fieldses.org>
References: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
	<20130624193153.GC23596@fieldses.org>
	<CADnca3vEfZZvWT_EfgBJ0AcmuUGXfVtGvasQqQQSAoQF7OLPJw@mail.gmail.com>
	<20130625134325.GA17511@fieldses.org>
Date: Tue, 25 Jun 2013 17:00:19 +0300
Message-ID: <CADnca3ugP74U7N5wBLHyu-X2Bi-Nz4B_8zLFOexRyhN7yNtYow@mail.gmail.com>
Subject: Re: LAYOUTGET and NFS4ERR_DELAY: a few questions
From: Nadav Shemer <nadav@tonian.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Lev <solo@tonian.com>,
        Idan Kedar <idank@tonian.com>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 25, 2013 at 4:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jun 25, 2013 at 02:51:48PM +0300, Nadav Shemer wrote:
>> On Mon, Jun 24, 2013 at 10:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > Attempting a summary: the constant delay is traditional behavior going
>> > back to NFSv3, and the exponential backoff was added to handle DELAY
>> > returns on OPEN due to delegation conflicts.
>> >
>> > And it would likely be tough to justify another client change here
>> > without a similar case where the spec clearly has the server returning
>> > DELAY to something that needs to be retried quickly.
>> >
>> > Not understanding your case, it doesn't sound like the result of any
>> > real requirement but rather an implementation detail that you probably
>> > want to fix in the server.
>> Well, a LAYOUTGET may cause a conflicting layout to be recalled (f.e.
>> RAID in object storage - RFC 5664, 11.).
>> Is that not similar to the
>> OPEN case?
>
> I'd expect there to be more options in the LAYOUTGET case, since a
> client can always fall back to MDS IO in the case of LAYOUTGET failure,
> whereas a failed OPEN is fatal.
Yes, but (the Linux client) only does so on permanent failure


>> This makes me ponder. If the server blocks while waiting for
>> conflicting layouts to be recalled, I think we can theoretically reach
>> a deadlock (if we take up all the nfsd threads or all the clients'
>> session slots): client A hold layout to file X, and requests layout to
>> file Y, while client B holds layout to file Y and requests layout to
>> file X.
>> To avoid this, we pretty much have to return DELAY for LAYOUTGET
>
> I agree that you wouldn't want to block waiting for a client to return a
> layout.  Is this a case for NFS4ERR_LAYOUTTRYLATER?
Yes, I believe it is.
Specifically the Linux client treats them all the same (LAYOUTTRYLATER
and RECALLCONFLICT are both mapped to DELAY before passing to
nfs4_async_handle_error)
Do you think there is a case for an exponential backoff in this case
for a specific (non-DELAY) error code?

>
> --b.
