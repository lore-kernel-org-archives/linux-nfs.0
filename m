From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 1/2] nfsd41: fix NFSD_MIN_HDR_SEQ_SZ
Date: Mon, 14 Sep 2009 16:11:20 -0400
Message-ID: <89c397150909141311i1cdff5f4v317b4addb8777de1@mail.gmail.com>
References: <1252709575-3426-1-git-send-email-andros@netapp.com>
	 <1252709575-3426-2-git-send-email-andros@netapp.com>
	 <20090914185120.GB1658@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.211.174]:60552 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933713AbZINULR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2009 16:11:17 -0400
Received: by ywh4 with SMTP id 4so4738134ywh.5
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 13:11:20 -0700 (PDT)
In-Reply-To: <20090914185120.GB1658@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2009 at 2:51 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Fri, Sep 11, 2009 at 06:52:54PM -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> The reply RPC header is 12 bytes, the NULL verifier is 8 bytes givin=
g 20
>> not 24 bytes in the NFSD_MIN_HDR_SEQ_SZ calculation,
>
> No, 24 is right. =A0Maybe you forgot the accept stat at the end?:

yes - missed the accept state.

-->Andy
>
> =A0 =A0 =A0 =A0xid
> =A0 =A0 =A0 =A0msg type
> =A0 =A0 =A0 =A0reply stat
> =A0 =A0 =A0 =A0verf flavor
> =A0 =A0 =A0 =A0verf length
> =A0 =A0 =A0 =A0accept stat
>
> --b.
>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfsd/nfs4state.c | =A0 =A04 ++--
>> =A01 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 46e9ac5..5ecb42c 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -420,12 +420,12 @@ gen_sessionid(struct nfsd4_session *ses)
>> =A0 * each time. =A0Therefore we can advertise a ca_maxresponssize_c=
ached
>> =A0 * value that is the number of bytes in our cache plus a few addi=
tional
>> =A0 * bytes. =A0In order to stay on the safe side, and not promise m=
ore than
>> - * we can cache, those additional bytes must be the minimum possibl=
e: 24
>> + * we can cache, those additional bytes must be the minimum possibl=
e: 20
>> =A0 * bytes of rpc header (xid through accept state, with AUTH_NULL
>> =A0 * verifier), 12 for the compound header (with zero-length tag), =
and 44
>> =A0 * for the SEQUENCE op response:
>> =A0 */
>> -#define NFSD_MIN_HDR_SEQ_SZ =A0(24 + 12 + 44)
>> +#define NFSD_MIN_HDR_SEQ_SZ =A0(20 + 12 + 44)
>>
>> =A0/*
>> =A0 * Give the client the number of ca_maxresponsesize_cached slots =
it
>> --
>> 1.6.2.5
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
