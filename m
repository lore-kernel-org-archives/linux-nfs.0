Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471Ab0DOLeK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Apr 2010 07:34:10 -0400
Message-ID: <4BC6F9AF.6070509@RedHat.com>
Date: Thu, 15 Apr 2010 07:34:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 10/22] gss_krb5: Add upcall info indicating supported
 	kerberos enctypes
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com> <y2t4d569c331004141130z7525d001gcdb81db5b1ede42e@mail.gmail.com>
In-Reply-To: <y2t4d569c331004141130z7525d001gcdb81db5b1ede42e@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/14/2010 02:30 PM, Kevin Coffman wrote:
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> index 8b612e7..d96d824 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> @@ -552,6 +552,7 @@ static struct gss_api_mech gss_kerberos_mech = {
>>        .gm_ops         = &gss_kerberos_ops,
>>        .gm_pf_num      = ARRAY_SIZE(gss_kerberos_pfs),
>>        .gm_pfs         = gss_kerberos_pfs,
>> +       .gm_upcall_enctypes = "enctypes=1,2,3 ",
>>  };
> 
> Hi Trond,
> This list should be in preference order.  It doesn't matter much with
> this one, but the preferred order for DES is usually "3,1,2".
> 
> When adding 3DES, the list should be "16,3,1,2"
> When adding AES, it should be "18,17,16,3,1,2"
> When adding RC4, it should be "18,17,16,23,3,1,2"
Ok... I went back and took a second look at this... The first
thing I did was put the gm_upcall_enctypes list back in
preference order. I had no idea there was actually a theory 
behind the order... 

Side Note: It appears the ordering really does not matter 
because the KDC is the one that decides (via the TGS-REP) which 
enctype will be used and (I've been told) the KDC will always 
pick the highest enctype possible. 

Now the reason root was not getting its context was
basically because of the following error (which I missed)
    ERROR: prepare_krb5_rfc_cfx_buffer: not implemented

Which was introduced by the third nfs-utils patch 
(Add support for non-DES encryption types) 
I'm currently investigating what that means...

So, Trond its up to you if you want to put that
list back in preference order, it will not matter
to the user space code...

steved.
