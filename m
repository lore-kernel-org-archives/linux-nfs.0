Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41256 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757502Ab0JLPiT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 11:38:19 -0400
Received: by bwz15 with SMTP id 15so2492467bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 08:38:18 -0700 (PDT)
In-Reply-To: <AANLkTingoh5XAeSvAWkN5pSWeixrY5vW0FrUQdW4b2bW@mail.gmail.com>
References: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
	<AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+@mail.gmail.com>
	<4CB4736F.2060507@panasas.com>
	<AANLkTingoh5XAeSvAWkN5pSWeixrY5vW0FrUQdW4b2bW@mail.gmail.com>
Date: Tue, 12 Oct 2010 11:38:18 -0400
Message-ID: <AANLkTinv9OZ1M9ykACYYavT57W69er_uTYXRiQA_aon9@mail.gmail.com>
Subject: Re: Question about LAYOUTRETURN stateid
From: Fred Isaman <iisaman@netapp.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: Benny Halevy <bhalevy@panasas.com>, "P.B.Shelley" <shelleypt@gmail.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 11:29 AM, William A. (Andy) Adamson
<androsadamson@gmail.com> wrote:
> I'll send one
>
> -->Andy

Another issue in the same code that could be fixed at the same time:
the set/invalidate stateid decision should not be under the type==FILE
check, but should always be done.

Fred

>
> On Tue, Oct 12, 2010 at 10:40 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-10-12 09:11, Fred Isaman wrote:
>>> On Tue, Oct 12, 2010 at 7:09 AM, P.B.Shelley <shelleypt@gmail.com> wrote:
>>>> Hi, all
>>>>
>>>> While reading Linux pnfs code, I have a question in layoutreturn code path.
>>>>
>>>> nfs4_layoutreturn_release() only invalidate layout stateid when
>>>> res.lrs_present is FALSE. If it is TRUE, client is supposed to set it
>>>> to res.stateid, is it? But I do not see somewhere the layout stateid
>>>> is updated. Am I missing something?
>>>>
>>>
>>> No, you are not missing anything.  that is a bug.
>>>
>>
>> Agreed.
>> Who's volunteering to send a fix? :)
>>
>> Benny
>>
>>> Fred
>>>
>>>> 5683 static void nfs4_layoutreturn_release(void *calldata)
>>>> 5684 {
>>>> 5685         struct nfs4_layoutreturn *lrp = calldata;
>>>> 5686         struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>>>> 5687
>>>> 5688         dprintk("--> %s return_type %d lo %p\n", __func__,
>>>> 5689                 lrp->args.return_type, lo);
>>>> 5690
>>>> 5691         if (lrp->args.return_type == RETURN_FILE) {
>>>> 5692                 if (!lrp->res.lrs_present)
>>>> 5693                         pnfs_invalidate_layout_stateid(lo);
>>>> 5694                 pnfs_layoutreturn_release(lo, &lrp->args.range);
>>>> 5695         }
>>>> 5696         kfree(calldata);
>>>> 5697         dprintk("<-- %s\n", __func__);
>>>> 5698 }
>>>>
>>>> --
>>>> Thanks,
>>>> Shelley
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
