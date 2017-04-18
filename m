Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32926 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754285AbdDRR2k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Apr 2017 13:28:40 -0400
Received: by mail-io0-f182.google.com with SMTP id k87so4830336ioi.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Apr 2017 10:28:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFX2JfkiraKm2Rmqhkrh3CSWBoYfW0QU=uXw=sSx-8Wt8JD7wg@mail.gmail.com>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org> <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
 <20170417133604.GA22694@fieldses.org> <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
 <CAFX2JfkiraKm2Rmqhkrh3CSWBoYfW0QU=uXw=sSx-8Wt8JD7wg@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 18 Apr 2017 13:28:39 -0400
Message-ID: <CAN-5tyEO3wJ3sT_phM6LNGH3zpYmi21e+fhHjkSGvZrRqWziMw@mail.gmail.com>
Subject: Re: [nfsv4] Inter server-side copy performance
To: Anna Schumaker <schumakeranna@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 17, 2017 at 11:37 AM, Anna Schumaker
<schumakeranna@gmail.com> wrote:
>
>
> On Mon, Apr 17, 2017 at 11:30 AM Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Mon, Apr 17, 2017 at 9:36 AM, J. Bruce Fields <bfields@fieldses.org>
>> wrote:
>> > On Fri, Apr 14, 2017 at 05:22:13PM -0400, Olga Kornievskaia wrote:
>> >> On Fri, Apr 14, 2017 at 4:09 PM, Mora, Jorge <Jorge.Mora@netapp.com>
>> >> wrote:
>> >> > On 4/13/17, 11:45 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> >> >> Are you timing just the copy_file_range() call, or do you include a
>> >> >> following sync?
>> >> >
>> >> > I am timing right before calling copy_file_range() up to doing an
>> >> > fsync() and close() of the destination file.
>> >> > For the traditional copy is the same, I am timing right before the
>> >> > first read on the source file up to the
>> >> > fsync() and close() of the destination file.
>> >>
>> >> Why should do we need a sync after copy_file_range(). kernel
>> >> copy_file_range() will send the commits for any unstable copies it
>> >> received.
>> >
>> > Why does it do that?  As far as I can tell it's not required by
>> > documentation for copy_file_range() or COPY.  COPY has a write verifier
>> > and a stable_how argument in the reply.  Skipping the commits would
>> > allow better performance in case a copy requires multiple COPY calls.
>> >
>> > But, in any case, if copy_file_range() already committed then it
>> > probably doesn't make a significant difference to the timing whether you
>> > include a following sync and/or close.
>>
>> Hm. It does make sense. Anna wrote the original code which included
>> the COMMIT after copy which I haven't thought about.
>>
>> Anna, any comments?
>
>
> I think the commit just seemed like a good idea at the time.  I'm okay with
> changing it if it doesn't make sense.

Given how the code is written now it looks like it's not possible to
save up commits....

Here's what I can see happening:

nfs42_proc_clone() as well as nfs42_proc_copy() will call
nfs_sync_inode(dst) "to make sure server(s) have the latest data"
prior to initiating the clone/copy. So even if we just queue up (not
send) the commit after the executing nfs42_proc_copy, then next call
into vfs_copy_file_range() will send out that queued up commit.

Is it ok to relax the requirement that requirement, I'm not sure...
