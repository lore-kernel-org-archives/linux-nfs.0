Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbbEGUEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 16:04:14 -0400
Message-ID: <554BC53C.5080807@RedHat.com>
Date: Thu, 07 May 2015 16:04:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>
CC: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <554B86E2.8090908@RedHat.com> <20150507163326.GA6156@suse.de> <554B98E9.4040601@RedHat.com> <20150507181206.GA7810@suse.de>
In-Reply-To: <20150507181206.GA7810@suse.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/07/2015 02:12 PM, Thorsten Kukuk wrote:
> On Thu, May 07, Steve Dickson wrote:
> 
>> On 05/07/2015 12:33 PM, Thorsten Kukuk wrote:
>>>>>>> Else here is my patch:
>>>>> Is this patch addition to Mike's patch?
>>> No, replacing it except the struct part.
>> So this is the complete patch..... 
>>
>> Look reasonable??
> 
> Some corrections:
> 
>> diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
>> index 44b38bf..4b9b0f1 100644
>> --- a/tirpc/rpc/svc_auth.h
>> +++ b/tirpc/rpc/svc_auth.h
> 
>> @@ -63,8 +69,10 @@ typedef struct SVCAUTH {
>>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>>  		} *svc_ah_ops;
>>  	caddr_t svc_ah_private;
>> +#ifdef HAVE_RPCSEC_GSS
>>  	svc_rpc_gss_parms_t svc_gss_params;
>>  	rpc_gss_rawcred_t raw_cred;
>> +#endif
>>  } SVCAUTH;
>>  
> 
> This needs to be "#ifdef HAVE_GSSAPI", HAVE_RPCSEC_GSS
> will never be defined if the header is used outside of
> libtirpc sources
When I do that I get the following errors when the gssapi is
enabled:

svc_auth_gss.c: In function 'rpc_gss_getcred':
svc_auth_gss.c:920:7: error: 'SVCAUTH' has no member named 'raw_cred'
   auth->raw_cred = gd->rcred;
       ^
svc_auth_gss.c:921:7: error: 'SVCAUTH' has no member named 'raw_cred'
   auth->raw_cred.service = _rpc_gss_svc_to_service(gd->sec.svc);
       ^
svc_auth_gss.c:922:32: error: 'SVCAUTH' has no member named 'raw_cred'
   (void)rpc_gss_num_to_qop(auth->raw_cred.mechanism, gd->sec.qop,
                                ^
svc_auth_gss.c:923:12: error: 'SVCAUTH' has no member named 'raw_cred'
       &auth->raw_cred.qop);
            ^
svc_auth_gss.c:924:17: error: 'SVCAUTH' has no member named 'raw_cred'
   *rcred = &auth->raw_cred;

I guess something is still broken in the configure.ac...
Looking into it.

> 
>> diff --git a/tirpc/tirpc-features.h b/tirpc/tirpc-features.h
>> new file mode 100644
>> index 0000000..7aec775
>> --- /dev/null
>> +++ b/tirpc/tirpc-features.h
> 
> 
> You should not tirpc/tirpc-features.h, only tirpc/tirpc-features.h.in
> tirpc/tirpc-features.h will be created by configure, like libtirpc.pc
> and config.h.
Ok... I'll add tirpc/tirpc-features.h to the .gitignore

Thanks again!

steved.


