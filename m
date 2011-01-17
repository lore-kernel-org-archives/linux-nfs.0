From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH] NFS4: Avoid potential NULL pointer dereference in decode_and_add_ds().
Date: Mon, 17 Jan 2011 14:09:31 -0500
Message-ID: <AANLkTimFfyT4M=0=mxfF4ZZjip2wbO27p_zUJg26TO2q@mail.gmail.com>
References: <alpine.LNX.2.00.1101162145290.13377@swampdragon.chaosbits.net>
	<AANLkTik+Z5C89Hb9Xu3az=deMsXj4rqvYpU=i7vXgdFx@mail.gmail.com>
	<alpine.LNX.2.00.1101171941560.27021@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51388 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab1AQTQP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jan 2011 14:16:15 -0500
In-Reply-To: <alpine.LNX.2.00.1101171941560.27021-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 17, 2011 at 1:42 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Mon, 17 Jan 2011, Fred Isaman wrote:
>
>> On Sun, Jan 16, 2011 at 3:50 PM, Jesper Juhl <jj@chaosbits.net> wrot=
e:
>> > strrchr() can return NULL if nothing is found. If this happens we'=
ll
>> > dereference a NULL pointer in
>> > fs/nfs/nfs4filelayoutdev.c::decode_and_add_ds().
>> >
>> > I tried to find some other code that guarantees that this can neve=
r
>> > happen but I was unsuccessful. So, unless someone else can point t=
o some
>> > code that ensures this can never be a problem, I believe this patc=
h is
>> > needed.
>> >
>>
>> The only guarantee is the assumption that the server isn't sending
>> garbage. =A0As such, this patch looks good to me.
>>
>
> Thanks. Can I add your Acked-by: if/when I resend the patch?
>

Yes.

=46red

> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
