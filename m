Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32250 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318AbcGZVWM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2016 17:22:12 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfsd: Close race between nfsd4_release_lockowner and nfsd4_lock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <B12516B5-503E-48D4-BE08-F1DC07D8EAAB@oracle.com>
Date: Tue, 26 Jul 2016 17:22:01 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8DF85CB6-5FEB-4A25-9715-C9808F37A4B1@oracle.com>
References: <20160713202810.19268.64046.stgit@klimt.1015granger.net> <20160714195542.GB16311@fieldses.org> <B12516B5-503E-48D4-BE08-F1DC07D8EAAB@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 14, 2016, at 4:25 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> 
>> On Jul 14, 2016, at 3:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>> On Wed, Jul 13, 2016 at 04:40:14PM -0400, Chuck Lever wrote:
>>> 
>>> The reason I was looking at this area is that one of our internal
>>> testers encountered a related problem with NFSv4.1. LOCK and
>>> FREE_STATEID are racing: LOCK returns an existing lock stateid, then
>>> FREE_STATEID frees that stateid (NFS4_OK). FREE_STATEID should
>>> return NFS4ERR_LOCKS_HELD in this case?
>> 
>> Looks like free_stateid is deciding whether to return LOCKS_HELD by
>> inspecting the list of vfs locks, but nfsd4_lock creates the lock
>> stateid before the vfs lock, so maybe there's a race like:
>> 
>> 	create lock stateid
>> 				free_stateid
>> 	vfs_lock_file
>> 
>> but I haven't checked that in detail.
> 
>> I haven't thought about the protocol side--does hitting this race
>> require an incorrect client?
> 
> I don't believe so, but there may be some subtlety I'm
> missing.
> 
> I have a network capture. The test is nfslock01 from LTP.
> There are two user processes that lock, write, and unlock
> alternating 64-byte pieces of the same file.
> 
> (stateid here is represented as "seqno / other")
> 
> On the wire, I see:
> 
> Frame 115004 C LOCK offset 672000 len 64
> Frame 115008 R LOCK NFS4_OK stateid 1/A
> Frame 115012 C WRITE stateid 0/A, offset 672000 len 64
> Frame 115016 R WRITE NFS4_OK
> Frame 115019 C LOCKU stateid 1/A 672000 len 64
> Frame 115022 R LOCKU NFS4_OK stateid 2/A
> Frame 115025 C FREE_STATEID stateid 2/A
> Frame 115026 C LOCK offset 672128 len 64
> Frame 115029 R FREE_STATEID NFS4_OK
> Frame 115030 R LOCK stateid 3/A
> Frame 115034 C WRITE stateid 0/A offset 672128 len 64
> Frame 115038 R WRITE NFS4ERR_BAD_STATEID
> Frame 115043 C TEST_STATEID stateid 3/A
> Frame 115044 R TEST_STATEID NFS4_OK
>                The returned stateid list has 3/A marked NFS4ERR_BAD_STATEID
> 
> Since the LOCKU and LOCK are accessing data segments
> 128 bytes apart, I assume these requests come from
> the same process on the client. The FREE_STATEID
> might be done in the background? which might be why
> it is sent concurrently with the LOCK.
> 
> IIUC, either the FREE_STATEID should have returned
> LOCKS_HELD, or the second LOCK should have returned
> a fresh lock state ID.
> 
> On my client I can't seem to get FREE_STATEID and
> LOCK to be sent concurrently, so the operations
> always come out in an order that guarantees the
> race is avoided.

Here's one possible scenario:

LOCK and FREE_STATEID are called simultaneously. The stateid passed
to FREE_STATEID has the same lock owner that is passed to the LOCK
operation.

nfsd4_lock is called. It gets to lookup_or_create_lock_stateid, which
takes cl_lock, finds the same stateid as was passed to FREE_STATEID,
drops cl_lock and returns. For some reason this thread is scheduled out.

This allows nfsd4_free_stateid to grab cl_lock. find_stateid_locked
finds the stateid, finds no lock state associated with the inode,
and decides to unhash the lock stateid. It drops cl_lock and
returns NFS4_OK.

nfsd4_lock resumes processing with the unhashed stateid. It completes
its processing, locks the file, and returns NFS4_OK and the dead
stateid.

Later the client uses that stateid in a WRITE. nfs4_preprocess_stateid_op
invokes nfsd4_lookup_stateid and then find_stateid_by_type. That might
find the stateid, but unhashing it earlier set sc_type to zero, and
now find_stateid_by_type returns NULL. WRITE returns BAD_STATEID.


--
Chuck Lever



