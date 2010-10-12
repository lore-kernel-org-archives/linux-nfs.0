From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: Question about LAYOUTRETURN stateid
Date: Tue, 12 Oct 2010 11:41:15 -0400
Message-ID: <AANLkTinjkWLywhBnGUQVC6rtG=FsTL9B5MZEF4jQ+1ci@mail.gmail.com>
References: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
	<AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+@mail.gmail.com>
	<4CB4736F.2060507@panasas.com>
	<AANLkTingoh5XAeSvAWkN5pSWeixrY5vW0FrUQdW4b2bW@mail.gmail.com>
	<AANLkTinv9OZ1M9ykACYYavT57W69er_uTYXRiQA_aon9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	"P.B.Shelley" <shelleypt@gmail.com>, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57096 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab0JLPlS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 11:41:18 -0400
Received: by iwn7 with SMTP id 7so893484iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 08:41:18 -0700 (PDT)
In-Reply-To: <AANLkTinv9OZ1M9ykACYYavT57W69er_uTYXRiQA_aon9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 12, 2010 at 11:38 AM, Fred Isaman <iisaman@netapp.com> wrot=
e:
> On Tue, Oct 12, 2010 at 11:29 AM, William A. (Andy) Adamson
> <androsadamson@gmail.com> wrote:
>> I'll send one
>>
>> -->Andy
>
> Another issue in the same code that could be fixed at the same time:
> the set/invalidate stateid decision should not be under the type=3D=3D=
=46ILE
> check, but should always be done.
>
> Fred

OK - I'll look that over.

-->Andy

>
>>
>> On Tue, Oct 12, 2010 at 10:40 AM, Benny Halevy <bhalevy@panasas.com>=
 wrote:
>>> On 2010-10-12 09:11, Fred Isaman wrote:
>>>> On Tue, Oct 12, 2010 at 7:09 AM, P.B.Shelley <shelleypt@gmail.com>=
 wrote:
>>>>> Hi, all
>>>>>
>>>>> While reading Linux pnfs code, I have a question in layoutreturn =
code path.
>>>>>
>>>>> nfs4_layoutreturn_release() only invalidate layout stateid when
>>>>> res.lrs_present is FALSE. If it is TRUE, client is supposed to se=
t it
>>>>> to res.stateid, is it? But I do not see somewhere the layout stat=
eid
>>>>> is updated. Am I missing something?
>>>>>
>>>>
>>>> No, you are not missing anything. =A0that is a bug.
>>>>
>>>
>>> Agreed.
>>> Who's volunteering to send a fix? :)
>>>
>>> Benny
>>>
>>>> Fred
>>>>
>>>>> 5683 static void nfs4_layoutreturn_release(void *calldata)
>>>>> 5684 {
>>>>> 5685 =A0 =A0 =A0 =A0 struct nfs4_layoutreturn *lrp =3D calldata;
>>>>> 5686 =A0 =A0 =A0 =A0 struct pnfs_layout_hdr *lo =3D NFS_I(lrp->ar=
gs.inode)->layout;
>>>>> 5687
>>>>> 5688 =A0 =A0 =A0 =A0 dprintk("--> %s return_type %d lo %p\n", __f=
unc__,
>>>>> 5689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lrp->args.return_type, lo);
>>>>> 5690
>>>>> 5691 =A0 =A0 =A0 =A0 if (lrp->args.return_type =3D=3D RETURN_FILE=
) {
>>>>> 5692 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lrp->res.lrs_present)
>>>>> 5693 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_invalid=
ate_layout_stateid(lo);
>>>>> 5694 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutreturn_release(lo=
, &lrp->args.range);
>>>>> 5695 =A0 =A0 =A0 =A0 }
>>>>> 5696 =A0 =A0 =A0 =A0 kfree(calldata);
>>>>> 5697 =A0 =A0 =A0 =A0 dprintk("<-- %s\n", __func__);
>>>>> 5698 }
>>>>>
>>>>> --
>>>>> Thanks,
>>>>> Shelley
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-n=
fs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.h=
tml
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nf=
s" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
