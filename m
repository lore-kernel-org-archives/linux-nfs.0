Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34731 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab0IMNBE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 09:01:04 -0400
Received: by bwz11 with SMTP id 11so4427254bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 06:01:03 -0700 (PDT)
In-Reply-To: <4C8DFDCC.8060906@panasas.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-9-git-send-email-iisaman@netapp.com>
	<1284147111.10062.74.camel@heimdal.trondhjem.org>
	<AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
	<1284158223.14078.78.camel@heimdal.trondhjem.org>
	<4C8DFDCC.8060906@panasas.com>
Date: Mon, 13 Sep 2010 06:01:03 -0700
Message-ID: <AANLkTimONZfA6ZX4xtzbmy0NdfEtbwMAi+__PhFYznTn@mail.gmail.com>
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 13, 2010 at 3:32 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-09-11 01:37, Trond Myklebust wrote:
>> On Fri, 2010-09-10 at 14:11 -0700, Fred Isaman wrote:
>>> On Fri, Sep 10, 2010 at 12:31 PM, Trond Myklebust
>>> <Trond.Myklebust@netapp.com> wrote:
>>>> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>>> OK
>>>
>>>>> +     .initialize_mountpoint   = filelayout_initialize_mountpoint,
>>>>> +     .uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
>>>>> +};
>>>>> +
>>>>> +
>>>>> +struct pnfs_layoutdriver_type filelayout_type = {
>>>>
>>>> Ditto.
>>>
>>> This includes a list_head field which is set by the generic layer.
>>>
>>>>
>>>>> +     .id = LAYOUT_NFSV4_1_FILES,
>>>>> +     .name = "LAYOUT_NFSV4_1_FILES",
>>>>> +     .ld_io_ops = &filelayout_io_operations,
>>>>
>>>> Why do we need a separate 'struct layoutdriver_io_operations'? Any
>>>> reason those can't just be embedded in struct pnfs_layoutdriver_type?
>>>
>>> I believe this decision was primarily aesthetics.  However, keeping
>>> the static io_ops seperate from the variable list_head seems like a
>>> good idea.
>>
>> I dunno. They are in a 1-1 correspondence, so I'm not sure I see the
>> need for a separation.
>>
>
> Later in the game we introduce the layout driver policy ops.
> That said, they could be added to the same vector as the io ops.


Yes, I think they should be merged when we get to that stage.


>
>>> Perhaps having a driver structure that includes the io_ops and static
>>> portions of pnfs_layoutdriver_type, with the generic layer allocating
>>> a wrapper structure that is basically:
>>> struct {
>>>     struct list_head list;
>>>     struct pnfs_layoutdriver_type *driver_info;
>>
>>       Should be const...
>>
>>       struct module *owner = THIS_MODULE;
>>
>>> }
>>
>> ...although the struct module could probably indeed be part of
>> pnfs_layoutdriver_type too.
>
> Agreed.
> I think we should just have
>
> struct pnfs_layoutdriver_type {
>        struct list_head pnfs_tblid;
>        const u32 id;
>        const char *name;
>        const struct module *owner;
>        const struct layoutdriver_operations *ld_ops;
>  };
>
> Benny
>

I'll point out that what I took from the above conversation, was that
the fields id, name, and possibly owner should be placed inside struct
layoutdriver_operations (which should probably be renamed slightly).


>>
>> Cheers
>>   Trond
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
