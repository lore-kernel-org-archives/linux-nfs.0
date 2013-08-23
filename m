Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39112 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406Ab3HWPYV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Aug 2013 11:24:21 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 5 0/3] Use the MDS nfs_server authflavor for
 pNFS data server connections
Date: Fri, 23 Aug 2013 15:24:19 +0000
Message-ID: <4CB61902-D1F5-4163-831B-92D071B47AF4@netapp.com>
References: <1376430469-3773-1-git-send-email-andros@netapp.com>
 <1377266509.2814.318.camel@willson.li.ssimo.org>
In-Reply-To: <1377266509.2814.318.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 23, 2013, at 10:01 AM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-08-13 at 17:47 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Differences from Version 4
>> - added NFSv4 Remove unused LIPKEY and SPKM enums
>> - shared GSS context caches when possible via shared rpc_clnt structs
> 
> If you share the gss context don't you risk mixing up sequence numbers
> and sending out of sequence packets ?

No, for a couple of reasons

1) RPCSEC_GSS requires that the GSS-API level sequencing is turned off - e.g. the sequence_req_flag is set to false.

rfc2203:

   When GSS_Init_sec_context() is called, the parameters
   replay_det_req_flag and sequence_req_flag must be turned off. The
   reasons for this are:

So the RPCSEC_GSS layer does the sequencing, not the GSS layer.

2) I'm not really sharing GSS contexts - just trying to avoid creating multiple GSS contexts per <principal, target> tuple. 

Really what I should be doing is creating a single GSS RPC auth cache for each supported RPC_AUTH_GSS pseudoflavor in the rpc_xprt struct, and have all rpc_clnt's that use the rpc_xprt use the GSS RPC auth. 

-->Andy


> Is that posible ? Is that going to be a problem with any
> implementation ?
> 
> I do not see GSS_C_SEQUENCE_FLAG used in nfs-utils, nor do I see any
> check for sequence in the unwrap call in the kernel so probably not a
> problem (at least for linux-to-linux), but just thought about asking to
> make sure anyway.



> 
> Simo.
> 
>> - DS conections use the shared rpc_clnts
>> 
>> Andy Adamson (3):
>>  NFSv4 Remove unused LIPKEY and SPKM enums
>>  NFS Share RPC_AUTH_GSS rpc clients
>>  NFSv4.1 Use the shared nfs_client rpc_clnts for pNFS data server
>>    connections
>> 
>> fs/nfs/client.c                 | 80 ++++++++++++++++++++++++++++++++++++++---
>> fs/nfs/internal.h               |  4 +++
>> fs/nfs/nfs4filelayout.c         | 69 +++++++++++++++++++++++++++++------
>> fs/nfs/nfs4filelayout.h         |  3 ++
>> fs/nfs/nfs4filelayoutdev.c      |  4 ++-
>> fs/nfs/nfs4namespace.c          |  5 +--
>> fs/nfs/nfs4proc.c               |  9 +++--
>> fs/nfs/nfs4state.c              |  4 +--
>> fs/nfs/super.c                  | 34 ------------------
>> include/linux/nfs_fs_sb.h       |  1 +
>> include/linux/sunrpc/msg_prot.h |  9 ++---
>> 11 files changed, 158 insertions(+), 64 deletions(-)
>> 
> 
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

