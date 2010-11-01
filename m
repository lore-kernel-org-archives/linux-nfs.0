Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18798 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab0KATpq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 15:45:46 -0400
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1288640536.5009.18.camel@heimdal.trondhjem.org>
Date: Mon, 1 Nov 2010 15:45:17 -0400
Cc: Nick Bowler <nbowler@elliptictech.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DA1E14E0-DCCD-4A6D-9471-E627D4BF2E85@oracle.com>
References: <20101101175854.GA3550@elliptictech.com> <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com> <20101101181938.GA3875@elliptictech.com> <187AEE96-9231-4899-9D65-A444503D2758@oracle.com> <1288639376.5009.16.camel@heimdal.trondhjem.org> <1288640536.5009.18.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 1, 2010, at 3:42 PM, Trond Myklebust wrote:

> On Mon, 2010-11-01 at 15:22 -0400, Trond Myklebust wrote:
>> I suspect nlmclnt_lookup_host() is to blame. It appears to be the _only_
>> thing in the kernel that actually sets this 'srcaddr' field, and it sets
>> it to
>> 
>> const struct sockaddr source = {
>> 	.sa_family      = AF_UNSPEC,
>> };
>> 
>> You triggered the bug by removing the line
>> 
>> 	transport->srcaddr.ss_family = family;
>> 
>> from xs_create_sock().
>> 
>>   Trond
> 
> Does this fix the regression?
> 
> Trond
> 
> ----------------------------------------------------------------------------------------------
> NLM: Fix a regression in lockd
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Nick Bowler reports:
> There are no unusual messages on the client... but I just logged into
> the server and I see lots of messages of the following form:
> 
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
> 
> Bisected to commit 9247685088398cf21bcb513bd2832b4cd42516c4 (SUNRPC:
> Properly initialize sock_xprt.srcaddr in all cases)
> 
> Apparently, removing the 'transport->srcaddr.ss_family = family' from
> xs_create_sock() triggers this due to nlmclnt_lookup_host() incorrectly
> initialising the srcaddr family to AF_UNSPEC.
> 
> Reported-by: Nick Bowler <nbowler@elliptictech.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
> fs/lockd/host.c |    5 -----
> 1 files changed, 0 insertions(+), 5 deletions(-)
> 
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 25e21e4..9ff0c0e 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -238,9 +238,6 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
> 				     const char *hostname,
> 				     int noresvport)
> {
> -	const struct sockaddr source = {
> -		.sa_family	= AF_UNSPEC,
> -	};
> 	struct nlm_lookup_host_info ni = {
> 		.server		= 0,
> 		.sap		= sap,
> @@ -249,8 +246,6 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
> 		.version	= version,
> 		.hostname	= hostname,
> 		.hostname_len	= strlen(hostname),
> -		.src_sap	= &source,
> -		.src_len	= sizeof(source),
> 		.noresvport	= noresvport,
> 	};
> 
> 


What about that memcpy() in nlm_lookup_host()?  With this patch, wouldn't it be copying garbage into the host's srcaddr field?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




