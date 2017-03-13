Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36419 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753412AbdCMOmw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Mar 2017 10:42:52 -0400
Received: by mail-io0-f174.google.com with SMTP id l7so85021062ioe.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Mar 2017 07:42:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1489352427.6645.1.camel@primarydata.com>
References: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
 <20170310213715.38258-1-kolga@netapp.com> <1489247175.3260.5.camel@primarydata.com>
 <A6FAD06E-0F4F-405E-871B-751E763BACB9@netapp.com> <1489352427.6645.1.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 13 Mar 2017 10:42:50 -0400
Message-ID: <CAN-5tyF3Ld-8EwbOenLxT-rL0gJTAW3szv-8sq29G3Y1itmsWg@mail.gmail.com>
Subject: Re: [PATCH 1/1] PNFS dont retry some error when MDS=DS
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kolga@netapp.com" <kolga@netapp.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 12, 2017 at 5:00 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Sun, 2017-03-12 at 14:40 -0400, Olga Kornievskaia wrote:
>> > On Mar 11, 2017, at 10:46 AM, Trond Myklebust <trondmy@primarydata.
>> > com> wrote:
>> >
>> > On Fri, 2017-03-10 at 16:37 -0500, Olga Kornievskaia wrote:
>> > > If we sent an operation to the "DS" and got an error, the code
>> > > resends
>> > > to "MDS" but when they are the same, it gets the same error and
>> > > goes
>> > > into the infinite loop. Example was COMMIT getting EACCES.
>> > >
>> >
>> > The correct behaviour when getting EACCES from a COMMIT to the MDS
>> > would be to retry the entire series of WRITE calls with stable
>> > writes.
>> > If the server then returns with anything other than FILE_SYNC, then
>> > EIO.
>> >

Going back to this comment. Then in non-pnfs (4.1 or 4.0), is the
expected behavior is to re-send the writes with FILE_SYNC. This is not
what the code does now.

>> > Why is the server failing the COMMIT here if the client thinks it
>> > sent
>> > unstable writes?
>>
>> This looping was discovered during connectathon testing against the
>> desy server. While I believe Tigran thinks there is an error in his
>> code and EACCES from COMMIT was unexpected, we thought that it would
>> be best if the client didn=E2=80=99t go into infinite loop in this condi=
tion
>> given that EACCES is a valid error for COMMIT. If you think this
>> shouldn=E2=80=99t happen in real life, then I=E2=80=99m ok with not purs=
uing this.
>
> It is legal, and I can sort of see how it might be invoked if a SETATTR
> changes the mode between the WRITE and the COMMIT, but it is a corner
> case.
>
>> On a different but related note, in case when MDS !=3D DS, when the
>> writes are retried they are not retried against the MDS but again are
>> sent to the DS, is that a bug?
>
> I would expect that once you decide to fall back to doing I/O through
> the MDS, then you'll want any resends to also go to the MDS.

I guess I'm not seeing there is a fallback happening if COMMIT fails.
I think if writes fail then fallback happens but not the COMMIT.

Again I'm not sure if this is worth pursing as you say it's a corner case.

>> >
>> > --
>> > Trond Myklebust
>> > Linux NFS client maintainer, PrimaryData
>> > trond.myklebust@primarydata.com
>>
>>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
