From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
	rpc_cred
Date: Tue, 25 May 2010 00:02:51 +0800
Message-ID: <AANLkTik-l_9nhBGWv-C8FKz9Aq99uP7-AWSi_uB4YDBG@mail.gmail.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>
	 <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>
	 <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN@mail.gmail.com>
	 <AANLkTinvXyrrqR7YpkLOUAJ890oTBdQCgQuNXD9o3gk-@mail.gmail.com>
	 <AANLkTikvP2aetI4bF-3ebus1Y91qFV4ahCXfxR_5ZNBN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40227 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757681Ab0EXQCw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 12:02:52 -0400
Received: by vws9 with SMTP id 9so2482519vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 09:02:51 -0700 (PDT)
In-Reply-To: <AANLkTikvP2aetI4bF-3ebus1Y91qFV4ahCXfxR_5ZNBN-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 24, 2010 at 9:43 PM, William A. (Andy) Adamson
<androsadamson@gmail.com> wrote:
> On Mon, May 24, 2010 at 2:37 AM, Tao Guo <glorioustao@gmail.com> wrote:
>> I see... But what if sync == 1? At that time, data must have already
>> been freed, so you should not use data->cred anymore.
>
> Agreed.
>
> Since LAYOUTCOMMIT is not called after close, we can get rid of taking
> the reference all together since a reference is taken on OPEN and
> dropped on CLOSE.
>
> -->Andy
I agree. However that will change several functions' interface I guess.

I still have a question: why some procedures need to set rpc_cred
whereas some needn't ? what is the connection between ctx's rpc_cred
and nfs4_state_owner's so_cred? Any guidance will be appreciated...

>>
>> --
>> tao.
>>
>



-- 
tao.
