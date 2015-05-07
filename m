Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbbEGPYX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 11:24:23 -0400
Message-ID: <554B8398.8020400@RedHat.com>
Date: Thu, 07 May 2015 11:24:08 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <20150507151252.GE30924@vapier>
In-Reply-To: <20150507151252.GE30924@vapier>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/07/2015 11:12 AM, Mike Frysinger wrote:
> On 07 May 2015 13:52, Thorsten Kukuk wrote:
>> On Thu, May 07, Mike Frysinger wrote:
>>> Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add header
>>> definitions for rpc_gss_*() APIs), the gss headers were pulled in all the
>>> time leading to build failures like so:
>>>   CC       libtirpc_la-bindresvport.lo
>>> In file included from ../tirpc/rpc/svc_auth.h:44:0,
>>>                  from ../tirpc/rpc/rpc.h:68,
>>>                  from bindresvport.c:46:
>>> ../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such file or directory
>>
>> Here is my proof of concept how I think we should solve this.
>> But there is one part of your patch I have no solution for:
>>
>>> --- a/tirpc/rpc/svc_auth.h
>>> +++ b/tirpc/rpc/svc_auth.h
>> [...]
>>> @@ -63,8 +67,10 @@ typedef struct SVCAUTH {
>>>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>>>  		} *svc_ah_ops;
>>>  	caddr_t svc_ah_private;
>>> +#ifdef HAVE_RPCSEC_GSS
>>>  	svc_rpc_gss_parms_t svc_gss_params;
>>>  	rpc_gss_rawcred_t raw_cred;
>>> +#endif
>>>  } SVCAUTH;
>>
>> You are changeing the size of a struct here. I'm not sure
>> if this will work, if an application is compiled with headers
>> where it is disabled and then runs with a tirpc where it is
>> enabled. Or the other way around.
>> Does somebody have an idea how to solve that?
> 
> i did notice that, but i would point out that this struct in the 0.2.5 lacked 
> these members.  they're new to the 0.3.0 release.  so if ABI is a concern, we 
> already lost that battle ;).
Right.. I knew this was the case... 

steved.

