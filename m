Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62091 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753249AbdDQP5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Apr 2017 11:57:50 -0400
Subject: Re: [nfsv4] Inter server-side copy performance
To: Olga Kornievskaia <aglo@umich.edu>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org>
 <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
 <20170417133604.GA22694@fieldses.org>
 <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <44273d82-18b5-a6c7-4c12-81297c84efb1@Netapp.com>
Date: Mon, 17 Apr 2017 11:57:41 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Resending because Google Inbox didn't switch to plain text)

On 04/17/2017 11:30 AM, Olga Kornievskaia wrote:
> On Mon, Apr 17, 2017 at 9:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Fri, Apr 14, 2017 at 05:22:13PM -0400, Olga Kornievskaia wrote:
>>> On Fri, Apr 14, 2017 at 4:09 PM, Mora, Jorge <Jorge.Mora@netapp.com> wrote:
>>>> On 4/13/17, 11:45 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>> Are you timing just the copy_file_range() call, or do you include a
>>>>> following sync?
>>>>
>>>> I am timing right before calling copy_file_range() up to doing an fsync() and close() of the destination file.
>>>> For the traditional copy is the same, I am timing right before the first read on the source file up to the
>>>> fsync() and close() of the destination file.
>>>
>>> Why should do we need a sync after copy_file_range(). kernel
>>> copy_file_range() will send the commits for any unstable copies it
>>> received.
>>
>> Why does it do that?  As far as I can tell it's not required by
>> documentation for copy_file_range() or COPY.  COPY has a write verifier
>> and a stable_how argument in the reply.  Skipping the commits would
>> allow better performance in case a copy requires multiple COPY calls.
>>
>> But, in any case, if copy_file_range() already committed then it
>> probably doesn't make a significant difference to the timing whether you
>> include a following sync and/or close.
> 
> Hm. It does make sense. Anna wrote the original code which included
> the COMMIT after copy which I haven't thought about.
> 
> Anna, any comments?

I think the commit just seemed like a good idea at the time.  I'm okay with changing it if it doesn't make sense.

Anna

> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
> 
