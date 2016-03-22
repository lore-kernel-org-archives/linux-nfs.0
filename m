Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39940 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbcCVVrU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2016 17:47:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: NFSv4.1: LOCK races with returning a delegation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <F530EBF6-F23B-41A7-AF4C-36141D691410@oracle.com>
Date: Tue, 22 Mar 2016 17:47:09 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2351A132-47CF-4C8A-BEF3-402ED565B3F1@oracle.com>
References: <F530EBF6-F23B-41A7-AF4C-36141D691410@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "Anna Schumaker@netapp com" <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 11, 2016, at 1:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Hi-
> 
> We observed some behavior at Connectathon between a
> v4.5-rc6 Linux client and a prototype Solaris 12 server
> when using NFSv4.1 on TCP. Test is xfstests generic/089.
> 
> At an earlier point, the client has been granted a
> write delegation, denoted below by "state=w", and has
> closed the file.
> 
> The sequence then observed on the wire is:
> 
>  C OPEN fh=A claim=DELEG_CUR_FH
>  C LOCK fh=A zero stateid
>  R OPEN NFS4_OK state=a
>  R LOCK NFS4ERR_BAD_STATEID
>  C TEST_STATEID state=a
>  R TEST_STATEID NFS4_OK
> 
>    client reports "Lock reclaim failed!"
> 
>  C LOCK fh=A state=a
>  R LOCK NFS4_OK
>  C DELEGRETURN state=w
>  R DELEGRETURN NFS4_OK
>  C RENAME -> .nfsXXXXXXXXXX
>  R RENAME NFS4_OK
> 
> I've reproduced the problem here at home. Sometimes
> the LOCK operation is emitted just _before_ the
> OPEN.
> 
> There are two processes involved. One is attempting
> to lock the file. The other is attempting to unlink
> the same file while it is still open.
> 
> I'm not sure why the client is emitting the LOCK
> operation at all, since it still holds a write
> delegation. The "Lock reclaim failed!" message
> seems to reflect this confusion: It expects to find
> and recover lock state, but there hasn't been a
> successful LOCK on that file yet.
> 
> After browsing the code, I don't see any serialization
> between taking a lock and returning a delegation on
> the same file, but my understanding in this area comes
> up short.
> 
> Is there a preferred way to serialize these two
> activities (like, a particular mutex that should be
> held) ?
> 
> Thanks for any guidance!

Following up.

Commit 24311f884 ('NFSv4: Recovery of recalled read
delegations is broken') introduced a

  clear_bit(NFS_DELEGATED_STATE, &state->flags);

in nfs_open_delegation_recall().

That flag is cleared before the OPEN is emitted, leaving
a window where NFS_DELEGATED_STATE is clear, but there is
no valid open stateid with which to perform a LOCK.

Moving the clear_bit() into the NFS4_OK case in
nfs4_handle_delegation_recall_error() seems to eliminate
the race.


--
Chuck Lever



