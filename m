Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123Ab2K0QoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 11:44:02 -0500
Message-ID: <50B4EDCF.3000704@RedHat.com>
Date: Tue, 27 Nov 2012 11:43:59 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Bruce Fields <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] gssd: Fix bugs in process_krb5_upcall
References: <1353969081-17842-1-git-send-email-Trond.Myklebust@netapp.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90B309AAD@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B309AAD@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27/11/12 11:05, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]
>> Sent: Monday, November 26, 2012 5:31 PM
>> To: Steve Dickson
>> Cc: Bruce Fields; linux-nfs@vger.kernel.org
>> Subject: [PATCH 1/2] gssd: Fix bugs in process_krb5_upcall
>>
>> The 'tgtname' parameter is the _server_ name, not the service name.
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>  utils/gssd/gssd_proc.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c index
>> ec251fa..b79e872 100644
>> --- a/utils/gssd/gssd_proc.c
>> +++ b/utils/gssd/gssd_proc.c
>> @@ -963,10 +963,8 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid,
>> int fd, char *tgtname,
>>  	printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
>>
>>  	if (tgtname) {
>> -		if (clp->servicename) {
>> -			free(clp->servicename);
>> -			clp->servicename = strdup(tgtname);
>> -		}
>> +		free(clp->servername);
>> +		clp->servername = strdup(tgtname);
>>  	}
>>  	token.length = 0;
>>  	token.value = NULL;
>> --
> 
> Sigh... Actually, this isn't right either. The log comment for commit 8b1c7bf5b624c9bc91b41ae577b9fc5c21641705 (rpc: add target field to new upcall) on the Linux client does indeed talk about who we want to authenticate to, but the choice of 'clnt->cl_principal' will actually give us our client hostname.
> 
> It turns out that nfs@"client hostname "is indeed the correct machine cred name when we're acting as the client, but when doing _callbacks_, the server has to authenticate using the same principal used by the client in the SETCLIENTID call (See Section 3.4, RFC3530). i.e. the nfs@hostname used does in fact include the NFS client's hostname (not the server's)!
> 
> So while PATCH 2/2 is still good, this patch appears to be incorrect and should be dropped for now.
> 
Duly noted... 

steved.
  
