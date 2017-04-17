Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35421 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754636AbdDQPaI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Apr 2017 11:30:08 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so25181612iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Apr 2017 08:30:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170417133604.GA22694@fieldses.org>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org> <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com> <20170417133604.GA22694@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 17 Apr 2017 11:30:06 -0400
Message-ID: <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
Subject: Re: [nfsv4] Inter server-side copy performance
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 17, 2017 at 9:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Apr 14, 2017 at 05:22:13PM -0400, Olga Kornievskaia wrote:
>> On Fri, Apr 14, 2017 at 4:09 PM, Mora, Jorge <Jorge.Mora@netapp.com> wrote:
>> > On 4/13/17, 11:45 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> >> Are you timing just the copy_file_range() call, or do you include a
>> >> following sync?
>> >
>> > I am timing right before calling copy_file_range() up to doing an fsync() and close() of the destination file.
>> > For the traditional copy is the same, I am timing right before the first read on the source file up to the
>> > fsync() and close() of the destination file.
>>
>> Why should do we need a sync after copy_file_range(). kernel
>> copy_file_range() will send the commits for any unstable copies it
>> received.
>
> Why does it do that?  As far as I can tell it's not required by
> documentation for copy_file_range() or COPY.  COPY has a write verifier
> and a stable_how argument in the reply.  Skipping the commits would
> allow better performance in case a copy requires multiple COPY calls.
>
> But, in any case, if copy_file_range() already committed then it
> probably doesn't make a significant difference to the timing whether you
> include a following sync and/or close.

Hm. It does make sense. Anna wrote the original code which included
the COMMIT after copy which I haven't thought about.

Anna, any comments?
