Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:26807 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878Ab3ICR5f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 13:57:35 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v2 15/33] NFS: Update session draining barriers for NFSv4.0 transport blocking
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1378230779.6410.13.camel@leira.trondhjem.org>
Date: Tue, 3 Sep 2013 13:57:31 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <75B1EFC0-8338-475A-B489-55AE360B07BF@oracle.com>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net> <20130809164956.5362.39856.stgit@seurat.1015granger.net> <1378230779.6410.13.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 3, 2013, at 1:52 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-08-09 at 12:49 -0400, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/nfs4state.c |   61 +++++++++++++++++++++++++++++-----------------------
>> 1 file changed, 34 insertions(+), 27 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 8826df3..d816d93 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -215,32 +215,6 @@ out:
>> 	return cred;
>> }
>> 
>> -#if defined(CONFIG_NFS_V4_1)
>> -
>> -static int nfs41_setup_state_renewal(struct nfs_client *clp)
>> -{
>> -	int status;
>> -	struct nfs_fsinfo fsinfo;
>> -
>> -	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
>> -		nfs4_schedule_state_renewal(clp);
>> -		return 0;
>> -	}
>> -
>> -	status = nfs4_proc_get_lease_time(clp, &fsinfo);
>> -	if (status == 0) {
>> -		/* Update lease time and schedule renewal */
>> -		spin_lock(&clp->cl_lock);
>> -		clp->cl_lease_time = fsinfo.lease_time * HZ;
>> -		clp->cl_last_renewal = jiffies;
>> -		spin_unlock(&clp->cl_lock);
>> -
>> -		nfs4_schedule_state_renewal(clp);
>> -	}
>> -
>> -	return status;
>> -}
>> -
>> static void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl)
>> {
>> 	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
>> @@ -254,6 +228,11 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
>> {
>> 	struct nfs4_session *ses = clp->cl_session;
>> 
>> +	if (clp->cl_slot_tbl) {
>> +		nfs4_end_drain_slot_table(clp->cl_slot_tbl);
>> +		return;
>> +	}
>> +
>> 	if (ses != NULL) {
>> 		nfs4_end_drain_slot_table(&ses->bc_slot_table);
>> 		nfs4_end_drain_slot_table(&ses->fc_slot_table);
>> @@ -278,6 +257,9 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
>> 	struct nfs4_session *ses = clp->cl_session;
>> 	int ret = 0;
>> 
>> +	if (clp->cl_slot_tbl)
>> +		return nfs4_drain_slot_tbl(clp->cl_slot_tbl);
>> +
>> 	/* back channel */
>> 	ret = nfs4_drain_slot_tbl(&ses->bc_slot_table);
>> 	if (ret)
>> @@ -286,6 +268,32 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
>> 	return nfs4_drain_slot_tbl(&ses->fc_slot_table);
>> }
>> 
>> +#if defined(CONFIG_NFS_V4_1)
>> +
>> +static int nfs41_setup_state_renewal(struct nfs_client *clp)
>> +{
>> +	int status;
>> +	struct nfs_fsinfo fsinfo;
>> +
>> +	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
>> +		nfs4_schedule_state_renewal(clp);
>> +		return 0;
>> +	}
>> +
>> +	status = nfs4_proc_get_lease_time(clp, &fsinfo);
>> +	if (status == 0) {
>> +		/* Update lease time and schedule renewal */
>> +		spin_lock(&clp->cl_lock);
>> +		clp->cl_lease_time = fsinfo.lease_time * HZ;
>> +		clp->cl_last_renewal = jiffies;
>> +		spin_unlock(&clp->cl_lock);
>> +
>> +		nfs4_schedule_state_renewal(clp);
>> +	}
>> +
>> +	return status;
>> +}
>> +
>> static void nfs41_finish_session_reset(struct nfs_client *clp)
>> {
>> 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>> @@ -2083,7 +2091,6 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
>> }
>> #else /* CONFIG_NFS_V4_1 */
>> static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
>> -static void nfs4_end_drain_session(struct nfs_client *clp) { }
>> 
>> static int nfs4_bind_conn_to_session(struct nfs_client *clp)
>> {
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> When compiling without CONFIG_NFS_V4_1:
> 
> [trondmy@leira linux-nfs]$ make O=../object.x86_64 W=1 C=2 fs/nfs/nfs4state.o
> make[2]: Nothing to be done for `all'.
> make[2]: Nothing to be done for `relocs'.
>  Using /home/trondmy/devel/kernel/linux-nfs as source for kernel
>  GEN     /home/trondmy/devel/kernel/object.x86_64/Makefile
>  CHK     include/generated/uapi/linux/version.h
>  CHK     include/generated/utsrelease.h
>  CALL    /home/trondmy/devel/kernel/linux-nfs/scripts/checksyscalls.sh
>  CHECK   /home/trondmy/devel/kernel/linux-nfs/scripts/mod/empty.c
>  CHECK   /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4state.c
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:29:23: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:34:16: warning: dereference of noderef expression
> /home/trondmy/devel/kernel/linux-nfs/include/linux/err.h:29:23: warning: dereference of noderef expression
>  CC [M]  fs/nfs/nfs4state.o
> /home/trondmy/devel/kernel/linux-nfs/fs/nfs/nfs4state.c:255:12: warning: ‘nfs4_begin_drain_session’ defined but not used [-Wunused-function]
> static int nfs4_begin_drain_session(struct nfs_client *clp)

That warning should be gone after "NFS: Add basic migration support to state manager thread".

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




