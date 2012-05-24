Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:41946 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758440Ab2EXRGq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2012 13:06:46 -0400
Subject: Re: [PATCH 1/2] nfs4.1: add BIND_CONN_TO_SESSION operation
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <84CCEB7E-7677-4383-B986-C3612D25FB6D@netapp.com>
Date: Thu, 24 May 2012 13:06:42 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Message-Id: <13A8DD85-EBD0-4A6D-9025-2FD83241EBD8@oracle.com>
References: <1337876797-17706-1-git-send-email-dros@netapp.com> <AB759F1A-91C0-4413-B2B9-9F7A9840AC7D@oracle.com> <84CCEB7E-7677-4383-B986-C3612D25FB6D@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 24, 2012, at 12:49 PM, Adamson, Dros wrote:

> 
> On May 24, 2012, at 12:46 PM, Chuck Lever wrote:
> 
>> 
>> On May 24, 2012, at 12:26 PM, Weston Andros Adamson wrote:
>> 
>>> This patch adds the BIND_CONN_TO_SESSION operation which is needed for
>>> upcoming SP4_MACH_CRED work and useful for recovering from broken connections
>>> without destroying the session.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/nfs4_fs.h        |    1 +
>>> fs/nfs/nfs4proc.c       |   54 ++++++++++++++++++++++++++++
>>> fs/nfs/nfs4xdr.c        |   90 +++++++++++++++++++++++++++++++++++++++++++++++
>>> include/linux/nfs4.h    |    5 +++
>>> include/linux/nfs_xdr.h |    6 +++
>>> 5 files changed, 156 insertions(+), 0 deletions(-)
>> 
>> [ ... snipped ... ]
>> 
>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>> index 0987146..80fbbfc6 100644
>>> --- a/include/linux/nfs4.h
>>> +++ b/include/linux/nfs4.h
>>> @@ -69,6 +69,10 @@
>>> #define NFS4_CDFC4_FORE_OR_BOTH 0x3
>>> #define NFS4_CDFC4_BACK_OR_BOTH 0x7
>>> 
>>> +#define CDFS4_FORE 0x1
>>> +#define CDFS4_BACK 0x2
>>> +#define CDFS4_BOTH 0x3
>> 
>> A few more nits:
>> 
>> I'm looking back at the patch I did last year to add BIND_CONN_TO_SESS for NFSv4.1 migration support... I used NFS4_CDFS4_FORE and so on here, to match the defines in the paragraph above.
> 
> Ah, good catch!  I'll change to NFS4_CDFS4_*
> 
>> 
>> In the XDR decoder function, I check the "dir_from_server" field to ensure it is equal to or less than NFS4_CDFS4_BOTH (-EIO if not).
> 
> Ok, that can't hurt!  Note I'm already returning EIO in the proc handler if dir != NFS4_CDFS4_BOTH,

Right, that's an implementation-imposed limit.  proc is the right place for that.  The XDR check is to sanity check servers, and should allow all possible values of that field, and no more.  FWIW.

> but I think it makes sense to add this sanity check.
> 
> Thanks!
> -dros
> 
>> 
>>> +
>>> #define NFS4_SET_TO_SERVER_TIME	0
>>> #define NFS4_SET_TO_CLIENT_TIME	1
>>> 
>>> @@ -582,6 +586,7 @@ enum {
>>> 	NFSPROC4_CLNT_SECINFO,
>>> 
>>> 	/* nfs41 */
>>> +	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
>>> 	NFSPROC4_CLNT_EXCHANGE_ID,
>>> 	NFSPROC4_CLNT_CREATE_SESSION,
>>> 	NFSPROC4_CLNT_DESTROY_SESSION,
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




