Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:28579 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465Ab3FYTFH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 15:05:07 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 Do not overwrite negotiated session sizes
Date: Tue, 25 Jun 2013 19:05:05 +0000
Message-ID: <4DF3A886-7DBA-4D8A-8111-29C1240C9487@netapp.com>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
 <1372185454-1888-2-git-send-email-andros@netapp.com>
 <1372186349.5968.45.camel@leira.trondhjem.org>
In-Reply-To: <1372186349.5968.45.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2013, at 2:52 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Tue, 2013-06-25 at 14:37 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> nfs4_init_session is called after CREATE_SESSION has set the ca_maxrequestsize
>> and ca_maxresponsesize values obtained from the server.
> 
> It had better not be, otherwise the values of
> session->fc_target_max_rqst_sz and session->fc_target_max_resp_sz in
> nfs4_init_channel_attrs() make no sense.

Well, it does. Shall I move the nfs4_init_session call to before nfs4_init_channel_attrs?

added dprintk and did a mount:

 --> nfs41_init_clientid
 --> nfs4_proc_create_session clp=ffff88005ff67800 session=ffff88005ff66c00
 nfs4_init_channel_attrs: Fore Channel : max_rqst_sz=1048576 max_resp_sz=1048576 max_ops=8 max_reqs=16
 nfs4_init_channel_attrs: BackChannel : max_rqst_sz=4096 max_resp_sz=4096 max_resp_sz_cached=0 max_ops=2 max_reqs=1

# ANDROS: set by server HERE
decode_chan_attrs max_resp_sz 81920
decode_chan_attrs max_resp_sz 4096

 --> nfs4_verify_fore_channel_attrs rcvd->max_resp_sz 81920
 --> nfs4_setup_session_slot_tables
 --> nfs4_realloc_slot_table: max_reqs=16, tbl->max_slots 0
 nfs4_realloc_slot_table: tbl=ffff88005ff66c40 slots=ffff88007a5edbc0 max_slots=16
 <-- nfs4_realloc_slot_table: return 0
 --> nfs4_realloc_slot_table: max_reqs=1, tbl->max_slots 0
 nfs4_realloc_slot_table: tbl=ffff88005ff66e08 slots=ffff88007a5ed640 max_slots=1
 <-- nfs4_realloc_slot_table: return 0
 slot table setup returned 0
 nfs4_proc_create_session client>seqid 2 sessionid 150994944:4550600:0:100925440
 <-- nfs4_proc_create_session
 nfs4_schedule_state_renewal: requeueing work. Lease period = 5

# ANDROS: Still correct when NFS4_CLNT_READY set:

 <-- nfs41_init_clientid clp->cl_session->fc_attrs->mas_resp_sz 81920

 Invoking bc_svc_process()

# ANDROS: Using session for RECLAIM COMPLETE

--> nfs41_proc_reclaim_complete

--> nfs41_setup_sequence
--> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=16
 <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
 <-- nfs41_setup_sequence slotid=0 seqid=1
 encode_sequence: sessionid=150994944:4550600:0:100925440 seqid=1 slotid=0 max_slotid=0 cache_this=0
 bc_svc_process() returned w/ error code= 0
 --> nfs4_reclaim_complete_done
 --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=1
 <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=-1
 nfs41_sequence_done: Error 0 free the slot
 nfs4_free_slot: slotid 0 highest_used_slotid -1
 <-- nfs4_reclaim_complete_done


 --> nfs_put_client({3})
 --> nfs4_match_clientids client ID c86f450000000009 matches c86f450000000009
 NFS: --> nfs4_match_serverowners server owners match
 NFS: <-- nfs41_walk_client_list using nfs_client = ffff88005ff67800 ({3})
 NFS: <-- nfs41_walk_client_list status = 0
 --> nfs_put_client({3})
 NFS: nfs4_discover_server_trunking: status = 0
 --> nfs_put_client({2})
 <-- nfs4_set_client() = 0 [new ffff88005ff67800]
 <-- nfs4_init_server() = 0

#ANDROS: after using the session, Now we init it????

 --> nfs4_init_session
 nfs4_init_session taking cl_lock
 nfs4_init_session test and clear case

#ANDROS - BUG - reset the max_resp_sz!!
 <-- nfs4_init_session session->fc_attrs.max_resp_sz 1049480

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

