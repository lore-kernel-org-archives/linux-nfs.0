From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: [PATCH 1/4] NLM: Kill PROC macro from NLMv1 and NLMv3 server
 procedures
Date: Fri, 17 Jul 2009 11:33:58 +0800
Message-ID: <4A5FF126.2000907@cn.fujitsu.com>
References: <4A5EF29B.1050100@cn.fujitsu.com>	 <4A5EF2FB.1010403@cn.fujitsu.com> <1247779647.12292.164.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60756 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S934074AbZGQDfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 23:35:03 -0400
In-Reply-To: <1247779647.12292.164.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Thu, 2009-07-16 at 17:29 +0800, Bian Naimeng wrote:
> 
>> +	[NLMPROC_NSM_NOTIFY] = {
>> +		.pc_func	= (svc_procfunc) nlmsvc_proc_sm_notify,
>> +		.pc_decode	= (kxdrproc_t) nlmsvc_decode_reboot,
>> +		.pc_encode	= (kxdrproc_t) nlmsvc_encode_void,
>> +		.pc_release	= NULL,
>> +		.pc_argsize	= sizeof(struct nlm_reboot),
>> +		.pc_ressize	= sizeof(struct nlm_void),
>> +		.pc_xdrressize	= 1,
>> +	},
>> +	NLMSVC_NONE_PROC,
>> +	NLMSVC_NONE_PROC,
>> +	NLMSVC_NONE_PROC,
> 
> Hmm... Does the C standard really allow you to mix C99 initialisers and
> K&R initialisers in this manner?
> 

  In this point, i think C99 is compatible with K&R. If it just support K&R
  but not C99, maybe " [subscript] = {}" should not work too.

  And i have tested with gcc, it can work with -std=c99 or -ansi option.

  And may i ask other questions.  

  Q: why we must initial these three procedures, is it in order to reply ok 
      to client?  

      But i have not finded that client will send these request.

      In RFC1813, we defined NLMPROC_NSM_NOTIFY = 16 and NLMPROC_SHARE = 20,
      but why not NLMPROC_SHARE = 17? 

      I try to find the reason, but failed. Would you answer my question or
      give me some suggestions. Thanks very much.
     
Best Regard
  Bian

> Cheers
>   Trond

