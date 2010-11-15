From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 16/22] pnfs-submit: rewrite of layout state handling and cb_layoutrecall
Date: Mon, 15 Nov 2010 09:28:38 -0500
Message-ID: <AANLkTi=5w_okZeO3K7Ar5mm7sCnD+P4fsi8Lqy115XUT@mail.gmail.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
	<1289551724-18575-17-git-send-email-iisaman@netapp.com>
	<1289639517.3669.9.camel@heimdal.trondhjem.org>
	<4CDFCB8D.7040209@panasas.com>
	<4CDFCCFB.4000402@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37711 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756885Ab0KOO2j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 09:28:39 -0500
Received: by bwz15 with SMTP id 15so5222935bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 06:28:38 -0800 (PST)
In-Reply-To: <4CDFCCFB.4000402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 14, 2010 at 6:50 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On 2010-11-14 13:44, Benny Halevy wrote:
>> On 2010-11-13 11:11, Trond Myklebust wrote:
>>> On Fri, 2010-11-12 at 03:48 -0500, Fred Isaman wrote:
>>>> + =A0 switch (cb_args->cbl_recall_type) {
>>>> + =A0 case RETURN_ALL:
>>>> + =A0 =A0 =A0 =A0 =A0 return true;
>>>> + =A0 case RETURN_FSID:
>>>> + =A0 =A0 =A0 =A0 =A0 return !memcmp(&NFS_SERVER(ino)->fsid, &cb_a=
rgs->cbl_fsid,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(struct=
 nfs_fsid));
>>>> + =A0 case RETURN_FILE:
>>>> + =A0 =A0 =A0 =A0 =A0 return (ino =3D=3D cb_info->pcl_ino) &&
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 should_free_lseg(range, &cb_=
args->cbl_range);
>>>> + =A0 default:
>>>> + =A0 =A0 =A0 =A0 =A0 BUG();
>>>
>>> Why should we BUG() just because the server is screwed up? That's n=
ot a
>>> client bug.
>>>
>>
>> Agreed. =A0This should be handled earlier in nfs4_callback_layoutrec=
all
>> or do_callback_layoutrecall so that we can return NFS4ERR_INVALID.
>>
>
> Actually NFS4ERR_BADXDR is the right error to return for a
> "value within the input stream that is not valid for the enum"
>
> Benny

OK.

=46red

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
