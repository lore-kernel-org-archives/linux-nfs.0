Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33096 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2BNOCZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 09:02:25 -0500
Received: by vbjk17 with SMTP id k17so3810085vbj.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Feb 2012 06:02:24 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4F38C8E4.6080901@tonian.com>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1328461679-4108-11-git-send-email-tigran.mkrtchyan@desy.de>
	<4F38C8E4.6080901@tonian.com>
Date: Tue, 14 Feb 2012 15:02:24 +0100
Message-ID: <CAGue13po_UFqN3niDG22beATNmfGTOjXNGuegGmXqCU8h92tKQ@mail.gmail.com>
Subject: Re: [PATH v8 10/10] nfsd41: use current stateid by value
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org, Tigran Mkrtchyan <kofemann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 13, 2012 at 9:25 AM, Benny Halevy <bhalevy@tonian.com> wrote:
> Sorry for the late response...
> If not committed yet, please fix the macros below.
>
> Otherwise
>
> Benny
>
> On 2012-02-05 19:07, Tigran Mkrtchyan wrote:
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 2ae378e..4ee102a 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -43,6 +43,13 @@
>>  #define NFSD4_MAX_TAGLEN     128
>>  #define XDR_LEN(n)                     (((n) + 3) & ~3)
>>
>> +#define CURRENT_STATE_ID_FLAG 1
>> +#define SAVED_STATE_ID_FLAG 2
>
> while at it, I'd rather define the flags as (1 << 0), (1 << 1)
> to stress the fact they are bit values.
>
>> +
>> +#define SET_STATE_ID(c, f) (c->sid_flags |= f)
>> +#define HAS_STATE_ID(c, f) (c->sid_flags & f)
>> +#define CLEAR_STATE_ID(c, f) (c->sid_flags &=  ~f)
>
> parenthesis must be used when using the macro arguments
> (important mainly for the last one, using the unary operator on the arg)
>
> +#define SET_STATE_ID(c, f) ((c)->sid_flags |= (f))
> +#define HAS_STATE_ID(c, f) ((c)->sid_flags & (f))
> +#define CLEAR_STATE_ID(c, f) ((c)->sid_flags &= ~(f))
>
> or just use the set_bit() test_bit() clear_bit() interface :)
set_bit() test_bit() clear_bit() operates on unsigned long int * which
is not the case here.

Tigran.
>
> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
