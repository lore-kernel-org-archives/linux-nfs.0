Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:35072 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdK3XDJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Nov 2017 18:03:09 -0500
Received: by mail-ua0-f176.google.com with SMTP id l2so6876506uak.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Nov 2017 15:03:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171130201823.GE3923@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <CAN-5tyHmrfKTfC8ELHA7RpHmUaVzBRKBqQNTpOYnu3SM7OdCnQ@mail.gmail.com>
 <CAN-5tyHumx9s7nkweA1B4CniPD_NzeGyd9d9FNL5ZxzX6KQ+zw@mail.gmail.com>
 <20171114004804.GB14185@parsley.fieldses.org> <CAN-5tyH2tEFsbVxhSdQqu8DW_7Zs4eHse4HWEN=vNAgKLiNSDQ@mail.gmail.com>
 <20171130201823.GE3923@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 30 Nov 2017 18:03:08 -0500
Message-ID: <CAN-5tyFY_VzFjG7D3gAjfr32AzxoT+OCZ-DWmT6zODkwFXWntw@mail.gmail.com>
Subject: Re: [PATCH v6 00/10] NFSD support for asynchronous COPY
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 30, 2017 at 3:18 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Nov 28, 2017 at 03:28:46PM -0500, Olga Kornievskaia wrote:
>> On Mon, Nov 13, 2017 at 7:48 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> > On Fri, Nov 10, 2017 at 10:01:02AM -0500, Olga Kornievskaia wrote:
>> >> On Fri, Nov 3, 2017 at 3:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >> > Bruce, any comments on this version?
>> >>
>> >> Bruce, do you have any comments on this version?
>> >
>> > I don't yet, apologies.  It is on my list to look at.
>> >
>>
>> Any ideas as to when that would be?
>
> Sorry for the silence.  I'll try to get it reviewed in time for 4.16.

I hope I won't forget too much in 3months for this ;)

> But I'm worrying about async behavior.  Just the usual complaint:
>
>         - A large copy could take anywhere from milliseconds to hours.

With the sync copy your worry was with tying up the nfsd thread. Here
each copy gets its own thread and doesn't interfere with other
operations. So why worry?

>         - The only way the protocol gives to measure progress is
>           OFFLOAD_STATUS, but I'm pessimistic that we'll get a
>           corresponding copy_progress syscall interface that
>           applications will get patched to use.

Doing a cp, never had a status info so what's different now.
Interested folks can do as before ls -l dst_file to monitor progress.

> So, currently the server's trying to avoid the problem by returning
> short COPY results and hoping applications will handle that gracefully
> (and that readahead and write behind will save performance).

We have demonstrated that doing async copy performs significantly
better (given large enough file size which was different between intra
and inter copy but something like 16MB). Really there is no point in
introducing an asynchronous copy unless you are doing all of it.

> But I guess that won't work in the server-to-server case.  Or would it?
> I *think* you can just send one NOTIFY

NOTIFY is only for "inter" server-to-server copy and we are currently
reviewing "asynchronous intra" copy?

> and then reuse the same stateid
> in multiple COPYs, so maybe it's not any worse than in the single-server
> case.

No you can not reuse the same stateid in multiple COPY's (spec doesn't
allow it). It has to uniquely identity the copy. Otherwise, when
client receives a reply from the async COPY it doesn't know which out
of those multiple copies to match it to.

> That would be a lot simpler if it worked.
>
> --b.
