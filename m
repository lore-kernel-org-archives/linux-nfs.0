Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:46425 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbaJIPd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Oct 2014 11:33:56 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so2510362qga.16
        for <linux-nfs@vger.kernel.org>; Thu, 09 Oct 2014 08:33:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <OFFD27669E.2EBBF381-ON88257D6B.00660543-88257D6B.0066A7EA@us.ibm.com>
References: <OF5715E76C.462C3FDF-ON88257D6B.00062E96-88257D6B.00088A0A@us.ibm.com>
 <610954AB-462F-4755-A777-3F89E3CAD5E6@primarydata.com> <OF547036CA.322A9587-ON88257D6B.0052B41D-88257D6B.0052F177@LocalDomain>
 <OFFD27669E.2EBBF381-ON88257D6B.00660543-88257D6B.0066A7EA@us.ibm.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 9 Oct 2014 11:33:35 -0400
Message-ID: <CAKVebiWm3jJ7xXBMD7RbFg3k2zHjXVwTWrFaLm_JOeVX16XGFA@mail.gmail.com>
Subject: Re: decode_device
To: Marc Eshel <eshel@us.ibm.com>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 8, 2014 at 2:41 PM, Marc Eshel <eshel@us.ibm.com> wrote:
> It looks like the problem is in the following line in decode_device()    p
> = xdr_inline_decode(&stream, cnt << 2);
> p is set to NULL
> is there a limitation in xdr to decode a stream that is bigger than 4096?
Here's the limitation in decode_device():
 78         /* set up xdr stream */
 79         scratch = alloc_page(gfp_flags);
 80         if (!scratch)
 81                 goto out_err;
 82
 83         xdr_init_decode_pages(&stream, &buf, pdev->pages, pdev->pglen);
 84         xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);

> it works fine for cnt of 1024 but not 1512
>
> Marc.
>
>
>
>
> From:   Marc Eshel/Almaden/IBM
> To:     Tom Haynes <thomas.haynes@primarydata.com>,
> Cc:     linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org, Marc
> Eshel/Almaden/IBM@IBMUS, Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   10/08/2014 08:05 AM
> Subject:        Re: decode_device
>
>
>
>
> linux-nfs-owner@vger.kernel.org wrote on 10/08/2014 05:46:24 AM:
>
>> From: Tom Haynes <thomas.haynes@primarydata.com>
>> To: Marc Eshel/Almaden/IBM@IBMUS,
>> Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-
>> nfs@vger.kernel.org
>> Date: 10/08/2014 05:46 AM
>> Subject: Re: decode_device
>> Sent by: linux-nfs-owner@vger.kernel.org
>>
>>
>> On Oct 7, 2014, at 9:33 PM, Marc Eshel <eshel@us.ibm.com> wrote:
>>
>> > I see that NFS4_PNFS_MAX_STRIPE_CNT is 4096 but when give the client a
> cnt
>> > that is bigger than 1024 it fails, is that the limitation of kcalloc()
> ?
>> >
>> > 366341.304362] <-- _nfs4_proc_getdeviceinfo status=0
>> > [366341.304364] filelayout_get_device_info getdevice info returns 0
>> > [366341.304368] decode_device stripe count  1512
>> > [366341.304370] decode_device ERROR: returning NULL
>> > [366341.304372] NFS: decode_and_add_device: Could not decode or add
> device
>> > [366341.304428] <-- filelayout_get_device_info dsaddr           (null)
>> > [366341.304430] --> filelayout_check_layout returns -22
>> > [366341.304433] pnfs_layout_process: Could not allocate layout: error
> -12
>> >
>> > decode_device()
>> >
>> > ...
>> >        dprintk("%s stripe count  %d\n", __func__, cnt);
>> >        if (cnt > NFS4_PNFS_MAX_STRIPE_CNT) {
>> >                printk(KERN_WARNING "NFS: %s: stripe count %d greater
> than
>> > "
>> >                       "supported maximum %d\n", __func__,
>> >                        cnt, NFS4_PNFS_MAX_STRIPE_CNT);
>> >                goto out_err_free_scratch;
>> >        }
>> >
>> >        /* read stripe indices */
>> >        stripe_indices = kcalloc(cnt, sizeof(u8), gfp_flags);
>> >        if (!stripe_indices)
>> >                goto out_err_free_scratch;
>> >
>> >
>> > Thanks, Marc.
>>
>>
>>
>> Hi Marc,
>>
>> You are asking for 1512 bytes of memory. That would be looking for a 2k
> slab.
>>
>> What flags are being passed down in gfp_flags?
>>
>> Are you experiencing any other memory issues?
>
> Hi Tom,
> It was working fine for a list of up to 1024 so I assumed it was a
> kcalloc, I will have to add more debugging to find the problem.
> Thanks, Marc.
>
>>
>> Tom
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
