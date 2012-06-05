Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934239Ab2FENgn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 09:36:43 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
Date: Tue, 5 Jun 2012 13:36:32 +0000
Message-ID: <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
 <1338571178-2096-2-git-send-email-andros@netapp.com>
 <4FCA98E7.2030006@panasas.com>
In-Reply-To: <4FCA98E7.2030006@panasas.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2012, at 6:51 PM, Boaz Harrosh wrote:

> On 06/01/2012 08:19 PM, andros@netapp.com wrote:
> 
>> From: Andy Adamson <andros@netapp.com>
>> 
>> When fencing, pnfs_return_layout can be called mulitple times with in-flight
>> i/o referencing lsegs on it's plh_segs list.
>> 
>> Remember that LAYOUTRETURN has been called, and do not call it again.
>> 
> 
> 
> NACK
> 
> In objects-layout we must report all errors on layout_return. We
> accumulate them and report of all errors at once. So we need
> the return after all in flights are back. (And no new IOs are
> sent) Otherwise we might miss some.

_pnfs_retrun_layout removes all layouts, and should therefore only be called once. I'll can add the 'wait for all in-flight' functionality, and we can switch behaviors (wait or not wait).

> Also the RFC mandates that we do not use any layout or have
> IOs in flight, once we return the layout.


You are referring to this piece of the spec?
Section 18.44.3   

  After this call,
   the client MUST NOT use the returned layout(s) and the associated
   storage protocol to access the file data.


The above says that  the client MUST NOT send any _new_ i/o using the layout.  I don't see any reference to in-flight i/o, nor should there be in the error case. I get a connection error. Did the i/o's I sent get to the data server?  The reason to send a LAYOUTRETURN without waiting for all the in-flights to return with a connection error is precisely to fence any in-flight i/o because I'm resending through the MDS.


> 
> I was under the impression that only when the last reference
> on a layout is dropped only then we send the lo_return.

> If it is not so, this is the proper fix.

> 
> 1. Mark LO invalid so all new IO waits or goes to MDS
> 3. When LO ref drops to Zero send the lo_return.

Yes for the normal case (evict inode for the file layout), but not if I'm in an error situation and I want to fence the DS from in-flight i/o.

> 4. After LAYOUTRETURN_DONE is back, re-enable layouts.
> I'm so sorry it is not so today. I should have tested for
> this. I admit that all my error injection tests are
> single-file single thread so I did not test for this.
> 
> Sigh, work never ends. Tell me if I can help with this

I'll add the wait/no-wait…

-->Andy

> Boaz
> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/pnfs.c |    6 ++++--
>> fs/nfs/pnfs.h |   13 +++++++++++++
>> 2 files changed, 17 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 854df5e..9ffd5f8 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -664,11 +664,11 @@ _pnfs_return_layout(struct inode *ino)
>> 	nfs4_stateid stateid;
>> 	int status = 0, empty = 0;
>> 
>> -	dprintk("--> %s\n", __func__);
>> +	dprintk("--> %s for inode %lu\n", __func__, ino->i_ino);
>> 
>> 	spin_lock(&ino->i_lock);
>> 	lo = nfsi->layout;
>> -	if (!lo) {
>> +	if (!lo || pnfs_test_layout_returned(lo)) {
>> 		spin_unlock(&ino->i_lock);
>> 		dprintk("%s: no layout to return\n", __func__);
>> 		return status;
>> @@ -705,6 +705,8 @@ _pnfs_return_layout(struct inode *ino)
>> 	lrp->clp = NFS_SERVER(ino)->nfs_client;
>> 
>> 	status = nfs4_proc_layoutreturn(lrp);
>> +	if (status == 0)
>> +		pnfs_mark_layout_returned(lo);
>> out:
>> 	dprintk("<-- %s status: %d\n", __func__, status);
>> 	return status;
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 29fd23c..8be6de2 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -64,6 +64,7 @@ enum {
>> 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
>> 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
>> 	NFS_LAYOUT_INVALID,		/* layout is being destroyed */
>> +	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
>> };
>> 
>> enum layoutdriver_policy_flags {
>> @@ -255,6 +256,18 @@ struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *
>> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>> void nfs4_deviceid_purge_client(const struct nfs_client *);
>> 
>> +static inline void
>> +pnfs_mark_layout_returned(struct pnfs_layout_hdr *lo)
>> +{
>> +	set_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
>> +}
>> +
>> +static inline bool
>> +pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
>> +{
>> +	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
>> +}
>> +
>> static inline int lo_fail_bit(u32 iomode)
>> {
>> 	return iomode == IOMODE_RW ?
> 
> 

