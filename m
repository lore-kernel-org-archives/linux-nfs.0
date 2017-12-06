Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54826 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdLFTJg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 14:09:36 -0500
Date: Wed, 6 Dec 2017 14:09:36 -0500
To: James Ettle <james@ettle.org.uk>
Cc: linux-nfs@vger.kernel.org, sparclinux@vger.kernel.org
Subject: Re: Unaligned access in gss_{get,verify}_mic_v2() on sparc64
Message-ID: <20171206190936.GB5875@fieldses.org>
References: <55549068-2605-7f71-ccef-c102d6fd69ab@ettle.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55549068-2605-7f71-ccef-c102d6fd69ab@ettle.org.uk>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 02, 2017 at 11:28:18PM +0000, James Ettle wrote:
> I've been using nfs4 with krb5 on sparc64 with kernel 4.13 and 4.14 and
> seeing a lot of messages like:
> 
> sparky kernel: [  105.262927] Kernel unaligned access at TPC[10afb234]
> gss_get_mic_kerberos+0xd4/0x360 [rpcsec_gss_krb5]
> 
> I've traced this down to gss_get_mic_v2() in gss_krb5_seal.c. I think
> the suspicious line is:
> 
> 	*((__be64 *)(krb5_hdr + 8)) = cpu_to_be64(seq_send);
> 
> krb5_hdr is void*, but comes from a u16 so won't generally have __be64
> alignment. As an experiment I added local variable
> 
> 	__be64 seq_send_be64;
> 
> and replaced the cpu_to_be64 line with:
> 
> 	seq_send_be64 = cpu_to_be64(seq_send);
> 	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);
> 
> There's another one in gss_verify_mic_v2() in gss_krb5_unseal.c. Here
> there's a line
> 
> 	if (be16_to_cpu(*((__be16 *)ptr)) != KG2_TOK_MIC)
> 
> but ptr is a u8*. For this I added local variable
> 
> 	__be16 data_be16;
> 
> and replaced the above if() with
> 
> 	memcpy((void *) &data_be16, (char *) ptr, 2);
> 	if (be16_to_cpu(data_be16) != KG2_TOK_MIC)
> 
> I've not seen any misalignment complaints yet with this.
> 
> I apologise for not sending this in the form of a patch, but this is
> only a sketch solution. I'm not a kernel hacker and I'm sure someone
> else will make a proper job of it!

Probably so.  But it might get done sooner if you do it.  There's the
added benefit that you can test the exact patch that gets applied.  You
can just:

	git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	<make your changes>
	git commit -a
	<write a changelog>

then send us the output of "git show".

--b.
