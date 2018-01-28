Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:53472 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbeA1QfA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jan 2018 11:35:00 -0500
Subject: Re: Unaligned access in gss_{get,verify}_mic_v2() on sparc64
From: James Ettle <james@ettle.org.uk>
To: linux-nfs@vger.kernel.org
Cc: sparclinux@vger.kernel.org
References: <55549068-2605-7f71-ccef-c102d6fd69ab@ettle.org.uk>
 <20171206190936.GB5875@fieldses.org>
 <8d4f1809-5027-46e7-1d21-d55f93950693@ettle.org.uk>
Message-ID: <2fad5cab-915c-a224-a1f1-b96a77a8546d@ettle.org.uk>
Date: Sun, 28 Jan 2018 16:34:57 +0000
MIME-Version: 1.0
In-Reply-To: <8d4f1809-5027-46e7-1d21-d55f93950693@ettle.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Just a polite prod in case it's fallen off the radar. The patch in this thread still applies cleanly to 4.14.15.

Thanks,
James.

On 07/12/17 01:42, James Ettle wrote:
> Patch from git as instructed:
> 
> 
> commit a90324ca784dea5a7259a2672c24626f5c03f576
> Author: James Ettle <james@ettle.org.uk>
> Date:   Thu Dec 7 00:50:28 2017 +0000
> 
>     Fix unaligned access on sparc64.
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
> index 1d74d653e6c0..94a2b3f082a8 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
> @@ -177,6 +177,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
>  	u64 seq_send;
>  	u8 *cksumkey;
>  	unsigned int cksum_usage;
> +	__be64 seq_send_be64;
> 
>  	dprintk("RPC:       %s\n", __func__);
> 
> @@ -187,7 +188,9 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
>  	spin_lock(&krb5_seq_lock);
>  	seq_send = ctx->seq_send64++;
>  	spin_unlock(&krb5_seq_lock);
> -	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
> +
> +	seq_send_be64 = cpu_to_be64(seq_send);
> +	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);
> 
>  	if (ctx->initiate) {
>  		cksumkey = ctx->initiator_sign;
> diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> index dcf9515d9aef..8ea6e30d6f3f 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
> @@ -155,10 +155,12 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
>  	u8 flags;
>  	int i;
>  	unsigned int cksum_usage;
> -
> +	__be16 be16_ptr;
> +	
>  	dprintk("RPC:       %s\n", __func__);
> 
> -	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_MIC)
> +	memcpy(&be16_ptr, (char *) ptr, 2);
> +	if (be16_to_cpu(be16_ptr) != KG2_TOK_MIC)
>  		return GSS_S_DEFECTIVE_TOKEN;
> 
>  	flags = ptr[2];
> 
> 
> 
> On 06/12/17 19:09, J. Bruce Fields wrote:
>> On Sat, Dec 02, 2017 at 11:28:18PM +0000, James Ettle wrote:
>>> I've been using nfs4 with krb5 on sparc64 with kernel 4.13 and 4.14 and
>>> seeing a lot of messages like:
>>>
>>> sparky kernel: [  105.262927] Kernel unaligned access at TPC[10afb234]
>>> gss_get_mic_kerberos+0xd4/0x360 [rpcsec_gss_krb5]
>>>
>>> I've traced this down to gss_get_mic_v2() in gss_krb5_seal.c. I think
>>> the suspicious line is:
>>>
>>> 	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
>>>
>>> krb5_hdr is void*, but comes from a u16 so won't generally have __be64
>>> alignment. As an experiment I added local variable
>>>
>>> 	__be64 seq_send_be64;
>>>
>>> and replaced the cpu_to_be64 line with:
>>>
>>> 	seq_send_be64 = cpu_to_be64(seq_send);
>>> 	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);
>>>
>>> There's another one in gss_verify_mic_v2() in gss_krb5_unseal.c. Here
>>> there's a line
>>>
>>> 	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_MIC)
>>>
>>> but ptr is a u8*. For this I added local variable
>>>
>>> 	__be16 data_be16;
>>>
>>> and replaced the above if() with
>>>
>>> 	memcpy((void *) &data_be16, (char *) ptr, 2);
>>> 	if (be16_to_cpu(data_be16) != KG2_TOK_MIC)
>>>
>>> I've not seen any misalignment complaints yet with this.
>>>
>>> I apologise for not sending this in the form of a patch, but this is
>>> only a sketch solution. I'm not a kernel hacker and I'm sure someone
>>> else will make a proper job of it!
>>
>> Probably so.  But it might get done sooner if you do it.  There's the
>> added benefit that you can test the exact patch that gets applied.  You
>> can just:
>>
>> 	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>> 	<make your changes>
>> 	git commit -a
>> 	<write a changelog>
>>
>> then send us the output of "git show".
>>
>> --b.
>>
