Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13472 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752796Ab3ETSue convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 14:50:34 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r4KIoXiN023240
	for <linux-nfs@vger.kernel.org>; Mon, 20 May 2013 11:50:34 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 Fix a pNFS session draining deadlock
Date: Mon, 20 May 2013 18:50:33 +0000
Message-ID: <21F7C2C8-C6CD-4BD7-B53A-2746B9D85593@netapp.com>
References: <1369073630-7193-1-git-send-email-andros@netapp.com>
 <1369074542.6115.8.camel@leira.trondhjem.org>
In-Reply-To: <1369074542.6115.8.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 20, 2013, at 2:29 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Mon, 2013-05-20 at 14:13 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> On a CB_RECALL the callback service thread flushes the inode using
>> filemap_flush prior to scheduling the state manager thread to return the
>> delegation. When pNFS is used and I/O has not yet gone to the data server
>> servicing the inode, a LAYOUTGET can preceed the I/O. Unlike the async
>> filemap_flush call, the LAYOUTGET must proceed to completion.
>> 
>> If the state manager starts to recover data while the inode flush is sending
>> the LAYOUTGET, a deadlock occurs as the callback service thread holds the
>> single callback session slot until the flushing is done which blocks the state
>> manager thread, and the state manager thread has set the session draining bit
>> which puts the inode flush LAYOUTGET RPC to sleep on the forechannel slot
>> table waitq.
>> 
>> Separate the draining of the back channel from the draining of the fore channel
>> by moving the NFS4_SESSION_DRAINING bit from session scope into the fore
>> and back slot tables.  Drain the back channel first allowing the LAYOUTGET
>> call to proceed (and fail) so the callback service thread frees the callback
>> slot. Then proceed with draining the forechannel.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/callback_proc.c |  2 +-
>> fs/nfs/callback_xdr.c  |  2 +-
>> fs/nfs/nfs4proc.c      |  2 +-
>> fs/nfs/nfs4session.c   |  6 ++++--
>> fs/nfs/nfs4session.h   | 13 ++++++++-----
>> fs/nfs/nfs4state.c     | 15 +++++++--------
>> 6 files changed, 22 insertions(+), 18 deletions(-)
>> 
> 
>> @@ -395,12 +395,14 @@ int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
>> 	/* Fore channel */
>> 	tbl = &ses->fc_slot_table;
>> 	tbl->session = ses;
>> +	tbl->slot_tbl_state = 0;
>> 	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
>> 	if (status) /* -ENOMEM */
>> 		return status;
>> 	/* Back channel */
>> 	tbl = &ses->bc_slot_table;
>> 	tbl->session = ses;
>> +	tbl->slot_tbl_state = 0;
>> 	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
>> 	if (status && tbl->slots == NULL)
>> 		/* Fore and back channel share a connection so get
> 
> Hi Andy,
> 

Hi Trond

> The above hunk is buggy. nfs4_setup_session_slot_tables() is called from
> nfs4_proc_create_session(), so it must not reset the
> NFS4_SLOT_TBL_DRAINING flag.

Yes - I see. Good catch
> 
> I'm therefore removing the above 2 lines. I've applied the rest of the
> patch.
> 
Thanks!

-->Andy

> Thanks!
>  Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

