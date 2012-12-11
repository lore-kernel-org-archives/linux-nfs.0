Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9038 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab2LKPdP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 10:33:15 -0500
Received: from vmwexceht01-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id qBBFWtRL009161
	for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2012 07:32:55 -0800 (PST)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: release clear_bit memory barrier
Date: Tue, 11 Dec 2012 15:32:54 +0000
Message-ID: <7851A663D3BF5E41B9E166C2C7A42145104FBF62@SACEXCMBX02-PRD.hq.netapp.com>
References: <1354298985-2344-1-git-send-email-andros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91191F135@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91191F135@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 10, 2012, at 3:02 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2012-11-30 at 13:09 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> A cleanup patch.
>> 
>> net/sunrpc/auth.c              |    1 +
>> net/sunrpc/auth_gss/auth_gss.c |    1 +
>> 2 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index b5c067b..8b76753 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -225,6 +225,7 @@ rpcauth_unhash_cred_locked(struct rpc_cred *cred)
>> 	hlist_del_rcu(&cred->cr_hash);
>> 	smp_mb__before_clear_bit();
>> 	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
>> +	smp_mb__after_clear_bit();
>> }
>> 
>> static int
>> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
>> index 909dc0c..92a7d6d 100644
>> --- a/net/sunrpc/auth_gss/auth_gss.c
>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>> @@ -126,6 +126,7 @@ gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
>> 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> 	smp_mb__before_clear_bit();
>> 	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
>> +	smp_mb__after_clear_bit();
>> }
>> 
>> static const void *
> 
> Why are these needed?

AFAICS the documentation says to either call both smp_mb__before_clear_bit and smp_mp__after_clear_bit to ensure that memory operations before and after the clear_bit call are strongly ordered, or don't call either. Since there can be multiple threads looking at a gss_cred cr_flags, it seems to me that we want the memory barriers to get the correct value of the bit.

-->Andy


from Documentation/atomic_ops.txt:

If explicit memory barriers are required around clear_bit() (which
does not return a value, and thus does not need to provide memory
barrier semantics), two interfaces are provided:

        void smp_mb__before_clear_bit(void);
        void smp_mb__after_clear_bit(void);

They are used as follows, and are akin to their atomic_t operation
brothers:

        /* All memory operations before this call will
         * be globally visible before the clear_bit().
         */
        smp_mb__before_clear_bit();
        clear_bit( ... );

        /* The clear_bit() will be visible before all
         * subsequent memory operations.
         */
         smp_mb__after_clear_bit();

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

