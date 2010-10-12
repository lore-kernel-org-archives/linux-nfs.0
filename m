From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: Question about LAYOUTRETURN stateid
Date: Tue, 12 Oct 2010 11:29:33 -0400
Message-ID: <AANLkTingoh5XAeSvAWkN5pSWeixrY5vW0FrUQdW4b2bW@mail.gmail.com>
References: <AANLkTikEYkC0Y0wf2GsOraCdK5BnB_NC7m_bgyaAwaWK@mail.gmail.com>
	<AANLkTik6WBUJrSW5GY+i-iERxU-rMz5D0oWFa-n8HhH+@mail.gmail.com>
	<4CB4736F.2060507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>,
	"P.B.Shelley" <shelleypt@gmail.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39933 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757474Ab0JLP3f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 11:29:35 -0400
Received: by iwn7 with SMTP id 7so881281iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 08:29:35 -0700 (PDT)
In-Reply-To: <4CB4736F.2060507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll send one

-->Andy

On Tue, Oct 12, 2010 at 10:40 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> On 2010-10-12 09:11, Fred Isaman wrote:
>> On Tue, Oct 12, 2010 at 7:09 AM, P.B.Shelley <shelleypt@gmail.com> w=
rote:
>>> Hi, all
>>>
>>> While reading Linux pnfs code, I have a question in layoutreturn co=
de path.
>>>
>>> nfs4_layoutreturn_release() only invalidate layout stateid when
>>> res.lrs_present is FALSE. If it is TRUE, client is supposed to set =
it
>>> to res.stateid, is it? But I do not see somewhere the layout statei=
d
>>> is updated. Am I missing something?
>>>
>>
>> No, you are not missing anything. =A0that is a bug.
>>
>
> Agreed.
> Who's volunteering to send a fix? :)
>
> Benny
>
>> Fred
>>
>>> 5683 static void nfs4_layoutreturn_release(void *calldata)
>>> 5684 {
>>> 5685 =A0 =A0 =A0 =A0 struct nfs4_layoutreturn *lrp =3D calldata;
>>> 5686 =A0 =A0 =A0 =A0 struct pnfs_layout_hdr *lo =3D NFS_I(lrp->args=
=2Einode)->layout;
>>> 5687
>>> 5688 =A0 =A0 =A0 =A0 dprintk("--> %s return_type %d lo %p\n", __fun=
c__,
>>> 5689 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lrp->args.return_type, lo);
>>> 5690
>>> 5691 =A0 =A0 =A0 =A0 if (lrp->args.return_type =3D=3D RETURN_FILE) =
{
>>> 5692 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lrp->res.lrs_present)
>>> 5693 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_invalidat=
e_layout_stateid(lo);
>>> 5694 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layoutreturn_release(lo, =
&lrp->args.range);
>>> 5695 =A0 =A0 =A0 =A0 }
>>> 5696 =A0 =A0 =A0 =A0 kfree(calldata);
>>> 5697 =A0 =A0 =A0 =A0 dprintk("<-- %s\n", __func__);
>>> 5698 }
>>>
>>> --
>>> Thanks,
>>> Shelley
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
