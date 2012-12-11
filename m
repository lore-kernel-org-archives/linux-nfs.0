Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:56186 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab2LKLVA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 06:21:00 -0500
Received: by mail-wg0-f46.google.com with SMTP id dr13so2397126wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 03:20:58 -0800 (PST)
Message-ID: <50C71712.2030909@tonian.com>
Date: Tue, 11 Dec 2012 13:20:50 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Marc Eshel <eshel@us.ibm.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@netapp.com>,
        Trond Myklebust <trond.myklebust@netapp.com>
Subject: Re: notify_deviceid_type4
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>	<50C45D17.5090000@tonian.com> <OFA6E36E77.727ADDF2-ON88257ACF.005B56C9-88257ACF.005BE4BB@us.ibm.com> <CAEMWVhsh0SvLX8MY8cghOmbYExpqFLYgUFVuai_RyaYu3EErvw@mail.gmail.com> <OF0F796F1E.99986A09-ON88257ACF.0063225B-88257ACF.0063629E@us.ibm.com>
In-Reply-To: <OF0F796F1E.99986A09-ON88257ACF.0063225B-88257ACF.0063629E@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-12-09 20:05, Marc Eshel wrote:
> Can you provide with the spec information that supports your 
> interpretation?

Marc, section 18.40.3. says the following:

   The notification mask is
   composed in the same manner as the bitmap for file attributes
   (Section 3.3.7).  The numbers of bit positions are listed in the
   notify_device_type4 enumeration type (Section 20.12).

The linux implementation chose to reflect the bit masks in the header
file rather than the bit numbers but it's clear the masks should equal
2 (1<<1) and 4 (1<<2) rather than 1 and 2.

For clarity, I'm OK with a patch that fixes the definition in nfs4.h to:

enum pnfs_notify_deviceid_type4 {
         NOTIFY_DEVICEID4_CHANGE = 1,
         NOTIFY_DEVICEID4_DELETE = 2,
};

But every place these values are currently used verbatim should be fixed
respectively to use the shifted value, e.g. (1 << NOTIFY_DEVICEID4_CHANGE).

Benny

> Marc.
> 
> 
> 
> From:   Benny Halevy <bhalevy@tonian.com>
> To:     Marc Eshel/Almaden/IBM@IBMUS, 
> Cc:     linux-nfs-owner@vger.kernel.org, Trond Myklebust 
> <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org, "J. Bruce Fields" 
> <bfields@redhat.com>
> Date:   12/09/2012 09:50 AM
> Subject:        Re: notify_deviceid_type4
> 
> 
> 
> The enum values in the spec correspond to bit _numbers_ in the bitmap, not 
> to bitmasks.
> On Dec 9, 2012 6:43 PM, "Marc Eshel" <eshel@us.ibm.com> wrote:
> I am not sure what you are saying, I am showing the definition from the
> spec. that show NOTIFY_DEVICEID4_CHANGE = 1, and nfs4.h has it as (1<< 1)
> which is not 1, it is 2.
> Marc.
> 
> Benny Halevy <bhalevy@tonian.com> wrote on 12/09/2012 01:42:47 AM:
> 
>> From: Benny Halevy <bhalevy@tonian.com>
>> To: Marc Eshel/Almaden/IBM@IBMUS,
>> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields"
>> <bfields@redhat.com>, linux-nfs-owner@vger.kernel.org, linux-
>> nfs@vger.kernel.org
>> Date: 12/09/2012 01:44 AM
>> Subject: Re: notify_deviceid_type4
>>
>> On 2012-12-01 07:54, Marc Eshel wrote:
>>> The spec defines notify_deviceid_type4 as:
>>>
>>> 20.12.1.  ARGUMENT
>>>    /*
>>>     * Device notification types.
>>>     */
>>>    enum notify_deviceid_type4 {
>>>            NOTIFY_DEVICEID4_CHANGE = 1,
>>>            NOTIFY_DEVICEID4_DELETE = 2
>>>    };
>>>
>>>
>>> but the Linux code in nfs4.h has, is that going to be fixed?
>>>
>>> enum pnfs_notify_deviceid_type4 {
>>>         NOTIFY_DEVICEID4_CHANGE = 1 << 1,
>>>         NOTIFY_DEVICEID4_DELETE = 1 << 2,
>>> };
>>
>> notify_deviceid_type4 specifies bit numbers same as notify_type4
>> It seems to me like the definition in nfs4.h is correct.
>>
>> Benny
>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
> 
> 

-- 
Benny Halevy
CTO, Tonian Inc.

Tel: +972-54-802-8340
bhalevy@tonian.com
