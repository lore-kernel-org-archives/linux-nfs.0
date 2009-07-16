From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] NLM: Kill PROC macro from NLMv1 and NLMv3 server
 procedures
Date: Thu, 16 Jul 2009 17:27:27 -0400
Message-ID: <1247779647.12292.164.camel@heimdal.trondhjem.org>
References: <4A5EF29B.1050100@cn.fujitsu.com>
	 <4A5EF2FB.1010403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56140 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933440AbZGPV1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 17:27:31 -0400
In-Reply-To: <4A5EF2FB.1010403@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-07-16 at 17:29 +0800, Bian Naimeng wrote:

> +	[NLMPROC_NSM_NOTIFY] = {
> +		.pc_func	= (svc_procfunc) nlmsvc_proc_sm_notify,
> +		.pc_decode	= (kxdrproc_t) nlmsvc_decode_reboot,
> +		.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,
> +		.pc_release	= NULL,
> +		.pc_argsize	= sizeof(struct nlm_reboot),
> +		.pc_ressize	= sizeof(struct nlm_void),
> +		.pc_xdrressize	= 1,
> +	},
> +	NLMSVC_NONE_PROC,
> +	NLMSVC_NONE_PROC,
> +	NLMSVC_NONE_PROC,

Hmm... Does the C standard really allow you to mix C99 initialisers and
K&R initialisers in this manner?

Cheers
  Trond

