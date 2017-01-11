Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:15449 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755969AbdAKTN1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 14:13:27 -0500
Subject: Re: [PATCH 00/11] Create a single nfs4_setup_sequence() function
To: Chuck Lever <chuck.lever@oracle.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
 <958E59EA-0BB8-4645-A387-7CE52EC65AD7@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <60076f9e-a8ff-6848-d35e-f649e32a21ce@Netapp.com>
Date: Wed, 11 Jan 2017 14:13:05 -0500
MIME-Version: 1.0
In-Reply-To: <958E59EA-0BB8-4645-A387-7CE52EC65AD7@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/11/2017 01:57 PM, Chuck Lever wrote:
> 
>> On Jan 11, 2017, at 1:54 PM, Anna.Schumaker@Netapp.com wrote:
>>
>> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>
>> I noticed that NFS v4.0 and v4.1 have different setup_sequence() functions
>> that are very, very similar.  I think we should try to share as much code
>> as possible whenever possible, so these patches merge together both versions
>> of this function using the presence of a session to decide if we need to do
>> a little extra work in some cases.
> 
> NFSv4.0 has a slot table these days to handle plugging the mount
> point during a migration. Hopefully that logic isn't fooled by
> your "has a session" test.

It shouldn't be.  The "has session" test was already there to select between the two functions I merged, so I'd expect everything to keep working.

Anna

> 
> 
>> I broke this change into several logical steps that (hopefully) make it easier
>> to follow what I did.
>>
>> Questions? Comments? Thoughts?
>> Anna
>>
>>
>> Anna Schumaker (11):
>>  NFS: Move nfs4_get_session() into nfs4_session.h
>>  NFS: Change nfs4_get_session() to take an nfs_client structure
>>  NFS: Change nfs4_setup_sequence() to take an nfs_client structure
>>  NFS: Use nfs4_setup_sequence() everywhere
>>  NFS: Create a single nfs4_setup_sequence() function
>>  NFS: Move slot-already-allocated check into nfs_setup_sequence()
>>  NFS: Lock the slot table from a single place during setup sequence
>>  NFS: Handle setup sequence task rescheduling in a single place
>>  NFS: Check if the slot table is draining from nfs4_setup_sequence()
>>  NFS: Merge the remaining setup_sequence functions
>>  NFS: Make trace_nfs4_setup_sequence() available to NFS v4.0
>>
>> fs/nfs/filelayout/filelayout.c         |   6 +-
>> fs/nfs/flexfilelayout/flexfilelayout.c |  40 ++----
>> fs/nfs/nfs42proc.c                     |   6 +-
>> fs/nfs/nfs4_fs.h                       |  15 +-
>> fs/nfs/nfs4proc.c                      | 244 +++++++++++----------------------
>> fs/nfs/nfs4session.h                   |   7 +
>> fs/nfs/nfs4trace.h                     |  64 ++++-----
>> 7 files changed, 139 insertions(+), 243 deletions(-)
>>
>> -- 
>> 2.11.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
