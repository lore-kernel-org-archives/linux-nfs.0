Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=66.163.188.212
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794448237;
	b=LhdQNn7F1IdCuzRamuSzENzIAHwSaAITi/r7m5iGJLjgaITHo0hAC7ZV7xGih4ug1t8C
	 MjM7L2l2nMlPar3rDLsNbnF66kOeKghqSzrjef+uSqpfZSLYPNkkMSZM1LJIuRSTlttzF
	 2Egd5Qi4j74M4czY0Uaz+ZlufCzclTqiYvKmSWmjICIJi/HSSL4SM6iOBIieXxSR6XPlM
	 0KvGDCjQowzvzEUcLsKujO+Gm61VxGKyvJRmuOBpjkbUGg0m5m34XVU0FpesGW0JnCCNr
	 Gd7e973Sp0U2SVEAlQRqNHQg285O8z7sgZoiQrm8WMfE4hTzWCAeLHYNvHJyseMkXDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794448237;
	h=DMARC-Filter:DKIM-Signature:X-SONIC-DKIM-SIGN:X-YMail-OSG:X-Sonic-MF:
	 X-Sonic-ID:Received:Received:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:Content-Language:From:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding:X-Mailer;
	bh=O8h9fybdyu+Al7CdWlfRBQ6LgqQutaBSF+Rc2HGjCVE=;
	b=cANzdJbkH4qAssQ46NNMMBrMOqeAmcC0w0SPXaMvPzS1dz6M4U4wZz6csQijRX95IQ9I
	 9Gu6CFOUNzG5fA4y5w4S17WIISrpRGtRIBl66mlukS1y1v4NvlhHMajgwNaQXsSR59Rg+
	 NDIQ36k/GzuHPOBMdyVn7nP/3lA/zDgRVuIgK67+H9wnwLDh1Q5r1+BpqqqCZ7oCVYeiB
	 oiavfz17mMlvN3v+yU5BSBsaK7/RPj4c7EHL63GYnGe2i9Wxtv5o/gC+e5muJFuEU3WNl
	 LUq33mHCATGm2voEw2rpSh4bBSHckpxWMxOMGbD3zz56Lbb5sMKKv+cqmP6/dp7+Vhw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=schaufler-ca.com;
	spf=pass smtp.mailfrom=schaufler-ca.com;
	dkim=pass header.d=yahoo.com header.i=@yahoo.com header.a=rsa-sha256 header.s=s2048 header.b=F+m434hx;
	arc=none smtp.remote-ip=66.163.188.212
Received: from sonic311-31.consmr.mail.ne1.yahoo.com (sonic311-31.consmr.mail.ne1.yahoo.com [66.163.188.212])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5293606A33E
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 01:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B5293606A33E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.a=rsa-sha256 header.s=s2048 header.b=F+m434hx
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1794448235; bh=O8h9fybdyu+Al7CdWlfRBQ6LgqQutaBSF+Rc2HGjCVE=; h=Date:Subject:To:Cc:References:From:In-Reply-To:Content-Type:From:Subject:Reply-To:Content-Type; b=F+m434hxnazo+znIsDN87b1q6q2BjDXrSK85l4sPO4/7/Nv6ouklEMGBpfrTHUnO8eGiNQoV5Bbw/uB3JZACliQBg8PtdTRYRP97HHZoegx3ArYwH69kAdVaUPkV7WcyNd89YKs91cZCwmWeziNsUM+FCRLahqzZW3a6Ku8pvIiJlMO/7XaKbdkzRicymfmmSk9XFsFNG+fkHI8UO70pZ1hFT9v2XQiwRrAslvpHUFbDR+3rpTT4Ikh/N/oSBL0qRMnhxDrBkdI0Mmku6tTsyJWpgcJjSTSvBuepznmh0kGiP8yElqSHRAm6ov8qvVTBbZJZj+71HtVfmpD+WAp7XA==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1794448235; bh=cB6ms4YZu3OSr7Oj5Ktyy9vRYllWqlKKBSjCDtAOhd3=; h=X-Sonic-MF:Date:Subject:To:From:From:Subject; b=Wh5tO+A7k6l9RAB9CmF+7nFPpV+s7vwQOvHRCpB836zmpk+EmZdiT1obFQYb3eEYUV/ZZrDMNSGrpqiSFrVBvEAP1+BcX3bVXL8AkZe5aM0djERGyxVy+oivb40ItIA89tHRP/kW5BzO7GaPGZrOTfFkDQF1HHnKQVH/ifoH5PYTL/BXjLkbPViq5JKecTMlRIryhz3iU6NkOHkP1F3oliaijdeTD+Tk00HCA4w802Q1PFZvsZSndMk6hlb4A1wMRPh3z4tVeu12oZckS5JIJR1ywCFknBKWBE+hVxojbZ57Qr3RCaKJrua5vLBD1s/SnsdmRZ+/JLOhUlVDaAQyJw==
X-YMail-OSG: zqmnDtkVM1n5t6ueog55b_vkFHSYM5E1qoECEJywzBr3UwiKAfUIVI_o6w7R9SH
 CQ1t93f4qyBpZEcVGjU2OBO9C0Of8.lRAD_UtcVdUMSf6_GiG98G7rNXb1ZhUGsyYLDyJE5oLG69
 MPpknxdoviNcfunvMa.q1ATsxUiRNZaaYFEtaSi7o3ARz3uzFbYwa4zXUFVTxVNR1M4yEm8E_vMu
 CX3lc6b1b0MWbnmh3DAeGebLmTpZwI12LuF9QH7MRRpV.Y7YkiPkkooycQl42qWPa_ZCsKSCVnTi
 cfYjzn7ZtEqmGYVjYEY1kEbVCA4JoS5GMMDKMoO39G5YhBugROnX2jrgGh0AwdwAby30.ZBxmd.l
 S62hS2hlPvIDoPxGhzS2whxCcIZrt8XbiUGRsBq2lfu8t9x.TIubZ4wIiRqzfDYoZIwioLDCjm6k
 .cljRFJEOnSix_ImX_sSyVP7eQAAEJ1GsHeUHb7atzAIHDlw0lV7YT_EQZaDbjuCghjYyGwMa7FJ
 LxdRDFOXlr05WMcbROqV0a4sd0J7UyT01rGVa2p8mqlfg_ZPSk1p0.zKLMJDr5A1o8n0sxe4LbiR
 qbREBgT6XAwECEJNbNHKO1YTM4iOmevp8GvnGDd6MDNapigfFoPwfu59SMy7zYd9LO3Z8_0VkIJt
 aPlGTgcyxBF.v1wQggIdb30_WaSmydGJlcGPdQ03irHq2wrwxiCoQO6IJUZEr0jypo3mUQnAGyDG
 k9vUUntKtCsyi.w0t_vFjR1T1M3Z6Xk5RLKDL9njS7LNW.CupQSEmNQ1GkX7kSwPFQP21HwmyMsp
 i9SdJowJ0s5y.bw2SrHxrP7sM6YbNToNL5ZVELMODpe5VuCBtDWl7VcCxYMmahr5455.ZE_hGmHs
 LrmFJx1uQ46OcZ2Ii956498sukETOy0INQsrtoq.ypS01I6QTO8GSI7rVFeq81ZNfcHhvUGJ06ME
 B8yJmeeVBase_8cBDx_Yk7y0xRppCWZz9S9bNwiHzQcmhSHJ99JaTf4E0zOIsgLWqU5tZh4wLZKp
 MnYneLIuBkBNwjBcYTuKXcpCwff8fTcsfan2g9ag6_HRqbKvb3lqTrnQRPIG.IGMBIXdu4D1HB2r
 Ygn65JHFmN1QF2ROBGshwilsGajQNSqHXHgx.co9RO5Evfjv8vx67t__1ew7rn3sc1C.7W_m4N4M
 cSR8SYdV43PcknGSee9yB1x8pWannWLYRUROzisZnoPLwDPX1S0a5pIeYojUo9jnHaAdfaOw5IJs
 bc0nB3tQZQ.0b782FrYX_n_pf05DxifKK1hrJ0OqXSo23BlRt.p63_4auT8X4tq9HTs9fxQLg0OA
 ydi2BtTIKopjFdQtWH0NOUC1U6_wILbgtZfZnlVsbVhHJ7Tk.UZGmAVff_vQl8b4id5D4T9jwtS9
 8nKfk1Ghey2tqeZDF9SgVACRH_x6kJa81R1e4J_83TMyBY4Ays_MTt39YbFzXRfBMRqG0I92h9IS
 Xl4i4wMK_gUqmjpP0P_oaDsTzptxLp7NMOmOY3T81w3i60pQpmuYMvggEU3dv.ebRC4Brat.KcXq
 ZyjrZ4BouQUvapbNSNNP1Y253sBId7Ys37DryRT0fCsyFp6LIN0DYA1xElaICSH34S2v84muDGZe
 .CGRnjEo0Q2679LeUfRrG7eDmdHtGbtXa02kyQjntuOc7VrR9y8jRUHqkLiiITgSdxH1QGB5PWuQ
 ARpFP1xjX3OHKFGeQd7o8WX3xDhKeppcWAPJEhIosno79RY0IQ4.4JX7WCaXgDYbj6BL4okuPPnu
 9CEiWKr_A1oRBHcXo_t2XyX1N2Jd1tPqjLAB1WY0vIGe1SVdGRdRloM6.RT24mU1pbFP4DjeRn1w
 _aXrAymHoztvd7BVNk78MI6f1URU2iBFJ6msmP6JgXQac5cfrtvlS9yn2eohnwEPfv__IKNy26n1
 mYs7i0yOvj6LH9jEvBJfejsFOAeuf8LBdL.MbTk8ZZiVorhzaxO81Zf4PRAQwZfM29CLtP5dAKbb
 klVicXy3HgsPrMZiM94qTb2yOlO2WSLEgrPS_2Vx31FNEHJNJpuKXHkfgTtKgjLPmpCr4Taq44yO
 KB8vbaoDybAHzNwFN22pWQG3NDp.x8aciLmMT8fUQgwMgW8NlLKb6ErL7ChYlwsHUhzhzMbUfvnT
 2bA6QlHpoN4OcRsGeb2ygbIpUCMhvL1tqClAnkg41oGlCJa3crNRCKKeXXqZBarf9KzLHJa8i581
 0YgHHROuHzbtZ8GRm6ggBoLbsrITMfTGKIshO9uwpGYYxl6nVscbC6LtZUsxlV5iP8t8XsYi.ga0
 EDsRWYHlK
X-Sonic-MF: <casey@schaufler-ca.com>
X-Sonic-ID: 4e6572e0-628c-4102-8309-f6caa349ac8e
Received: from sonic.gate.mail.ne1.yahoo.com by sonic311.consmr.mail.ne1.yahoo.com with HTTP; Thu, 12 Nov 2026 01:50:35 +0000
Received: by hermes--production-gq1-fd7994565-9vhlr (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID 15d81e1a8a6348ae9dcd84771e3b8196;
          Thu, 12 Nov 2026 01:50:33 +0000 (UTC)
Message-ID: <41617b0a-90d9-484e-a143-78e2a92e872c@schaufler-ca.com>
Date: Wed, 11 Nov 2026 17:50:30 -0800
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [apparmor] [PATCH RFC 19/41] smack: use fc_init_pseudo() for
 smackfs
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: linux-efi@vger.kernel.org, Jan Kara <jack@suse.cz>,
 Amir Goldstein <amir73il@gmail.com>, linux-nvme@lists.infradead.org,
 fuse-devel@lists.linux.dev, linux-mm@kvack.org,
 target-devel@vger.kernel.org, linux-kselftest@vger.kernel.org,
 Chris Mason <mason@kernel.org>, Christoph Hellwig <hch@lst.de>,
 linux-s390@vger.kernel.org, linux-erofs@lists.ozlabs.org,
 linux-scsi@vger.kernel.org, xen-devel@lists.xenproject.org,
 driver-core@lists.linux.dev, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
 Josef Bacik <josef@toxicpanda.com>, linux-block@vger.kernel.org,
 ocfs2-devel@lists.linux.dev, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, bpf@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, Casey Schaufler <casey@schaufler-ca.com>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-19-4c998976c6c7@kernel.org>
Content-Language: en-US
From: Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <20261110-work-loop-pseudo-v1-19-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Mailer: WebService/1.1.26943 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

On 11/10/2026 1:14 AM, Christian Brauner via AppArmor wrote:
> Initialize smackfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. smackfs never holds executables or
> device nodes.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Please include me at least as a CC on Smack patches.
I ain't dead yet. Nonetheless,

Acked-by: Casey Schaufler <casey@schaufler-ca.com>

> ---
>  security/smack/smackfs.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index a72bc7fabea9..4a56bbeaeca3 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -25,6 +25,7 @@
>  #include <linux/magic.h>
>  #include <linux/mount.h>
>  #include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
>  #include "smack.h"
>  
>  #define BEBITS	(sizeof(__be32) * 8)
> @@ -2880,6 +2881,7 @@ static const struct fs_context_operations smk_context_ops = {
>   */
>  static int smk_init_fs_context(struct fs_context *fc)
>  {
> +	fc_init_pseudo(fc);
>  	fc->ops = &smk_context_ops;
>  	return 0;
>  }
>
