Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35462 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbdALQvb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 11:51:31 -0500
Received: by mail-qt0-f174.google.com with SMTP id x49so23313591qtc.2
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 08:51:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112161005.GA8589@fieldses.org>
References: <20170104165636.GA17649@fieldses.org> <20170112021703.GC18977@fieldses.org>
 <CAHVgHyWeGj4GGap8axPnaJYAOBup=LXdeVdQ3fz1o6q7JWkT_w@mail.gmail.com> <20170112161005.GA8589@fieldses.org>
From: Andy Adamson <androsadamson@gmail.com>
Date: Thu, 12 Jan 2017 11:51:30 -0500
Message-ID: <CAHVgHyVWUbjLRTdYL+akkVLOGURKO1tFm_02d4P8TO-gQKRWEg@mail.gmail.com>
Subject: Re: RFC: make labeled NFS opt-in
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS list <linux-nfs@vger.kernel.org>, tibbs@math.uh.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2017 at 11:10 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jan 12, 2017 at 10:29:14AM -0500, Andy Adamson wrote:
>> NFSv4.2 labeled NFS provides 'guest mode' Mandatory Access Control
>> (MAC) where the client can enforce labeling and store a label on the
>> server, but the server itself does not enforce the same MAC as the
>> client because the client request thread label is unknown to the
>> server. RPCSEC_GSS version 3 label assertions asserts the client
>> thread label on the NFSD thread handling the request, and so along
>> with LNFS provides Full Mode MAC.
>>
>> AFAICS the only time we want GSS3 label assertions is if LNFS is
>> enabled.  Does this sound right to you? If so, I will use this new per
>> export LNFS option to determine when GSS3 label assertions are
>> enabled.
>
> How do you disable or enable this on the server side?

In nfsd_setuser, if the rq_authop has the new set_label operation, and
selinux_is_enabled() then the label is asserted.

>
> I haven't been following the GSS3 development well, apologies.  So I
> guess you must do something like:
>
>         1. decode the GSS3 stuff in the RPC layer and store the
>         resulting subject label somewhere like rqstp->rq_cred.
>         2. in nfsd_setuser, set the nfsd thread's label to the label
>         stored in rq_cred.


Yes, I do both of those tasks.

>
> You probably need to have the processing in step 1 enabled all the time,
> because you don't know which export you're going to be dealing with yet
> at that point.

Yes.

>
> By step 2 you have the export.  So I guess you'd use the export option
> to decide whether to silently ignore the label, or apply it to the nfsd
> thread?

yes.

>
> That might make sense.

Good! That is easy to add and is what I am thinking.

I'm building the gss prototype against your latest nfsd-next. Once I
test it, i'll send in version 4.

-->Andy

>
> --b.
