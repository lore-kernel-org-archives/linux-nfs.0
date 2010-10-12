From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Question about LAYOUTRETURN stateid
Date: Tue, 12 Oct 2010 10:40:47 -0400
Message-ID: <4CB4736F.2060507@panasas.com>
References: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com> <AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "P.B.Shelley" <shelleypt@gmail.com>, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:58249 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757360Ab0JLOks (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 10:40:48 -0400
In-Reply-To: <AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-10-12 09:11, Fred Isaman wrote:
> On Tue, Oct 12, 2010 at 7:09 AM, P.B.Shelley <shelleypt@gmail.com> wrote:
>> Hi, all
>>
>> While reading Linux pnfs code, I have a question in layoutreturn code path.
>>
>> nfs4_layoutreturn_release() only invalidate layout stateid when
>> res.lrs_present is FALSE. If it is TRUE, client is supposed to set it
>> to res.stateid, is it? But I do not see somewhere the layout stateid
>> is updated. Am I missing something?
>>
> 
> No, you are not missing anything.  that is a bug.
> 

Agreed.
Who's volunteering to send a fix? :)

Benny

> Fred
> 
>> 5683 static void nfs4_layoutreturn_release(void *calldata)
>> 5684 {
>> 5685         struct nfs4_layoutreturn *lrp = calldata;
>> 5686         struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>> 5687
>> 5688         dprintk("--> %s return_type %d lo %p\n", __func__,
>> 5689                 lrp->args.return_type, lo);
>> 5690
>> 5691         if (lrp->args.return_type == RETURN_FILE) {
>> 5692                 if (!lrp->res.lrs_present)
>> 5693                         pnfs_invalidate_layout_stateid(lo);
>> 5694                 pnfs_layoutreturn_release(lo, &lrp->args.range);
>> 5695         }
>> 5696         kfree(calldata);
>> 5697         dprintk("<-- %s\n", __func__);
>> 5698 }
>>
>> --
>> Thanks,
>> Shelley
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
