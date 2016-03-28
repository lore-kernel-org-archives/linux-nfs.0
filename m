Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23337 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbcC1RAr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 13:00:47 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC] xprtrdma: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtRpaPMvFPK4Q8LGUOf6FhuQbFf6UorWcXYUkAKMyXEO_w@mail.gmail.com>
Date: Mon, 28 Mar 2016 13:00:42 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Message-Id: <0A592243-07A4-4E12-A10E-39F168B26C25@oracle.com>
References: <20160328155114.19702.71714.stgit@manet.1015granger.net> <CAHQdGtRpaPMvFPK4Q8LGUOf6FhuQbFf6UorWcXYUkAKMyXEO_w@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 28, 2016, at 12:30 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Hi Chuck,
> 
> On Mon, Mar 28, 2016 at 11:51 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> At Connectathon 2016, we found that recent upstream Linux clients
>> would occasionally send a LOCK operation with a zero stateid. This
>> appeared to happen in close proximity to another thread returning
>> a delegation before unlinking the same file while it remained open.
>> 
>> Earlier, the client received a write delegation on this file and
>> returned the open stateid. Now, as it is getting ready to unlink the
>> file, it returns the write delegation. But there is still an open
>> file descriptor on that file, so the client must OPEN the file
>> again before it returns the delegation.
>> 
>> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
>> delegations is broken'), nfs_open_delegation_recall() clears the
>> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
>> racing LOCK on the same inode to be put on the wire before the OPEN
>> operation has returned a valid open stateid.
>> 
>> After the OPEN(CLAIM_DELEG_CUR_FH) returns, the client holds both
>> a write delegation and a valid open stateid. It is safe to clear
>> NFS_DELEGATED_STATE at that point, allowing fresh lock requests
>> to go on the wire using the newly acquired open stateid.
>> 
>> I'm not certain of this fix. nfs4_handle_delegation_recall_error()
>> is called from both nfs_open_delegation_recall() and
>> nfs_lock_delegation_recall(). Is it safe and correct to clear
>> NFS_DELEGATED_STATE after success in both of these code paths?
>> 
> 
> I'm not seeing why the subject line is tagged as describing an
> xprtrdma issue. Was that intentional?

No, it was just habit. I'll remove it.


> Secondly, would it perhaps make more sense to have the locking code
> simply wait for the outstanding delegation return recovery? Otherwise,
> I worry that we are exchanging one timing-specific problem for
> another.

Sure, that's a doubt I have as well.

My understanding of this is not sophisticated, but
it seems safe to switch to using on-the-wire locks
once the client holds a delegation and an open
stateid.

Then after that, flush any remaining cached locks.
New application lock requests can go to the server
concurrently. The VFS layer should sort out conflicts
(copying Jeff for his thoughts).

Finally, return the delegation, allowing other
clients to open/lock the file.

That seems to be what that code path is doing already.

Is there another window in there where an application
might drive open or lock system calls that could result
in an indeterminant result?

Serializing locking and delegation return would have a
negative performance impact on common locking operations
(even when they are cached), I would think, as it would
have to be a mutex or something even more heavyweight.


--
Chuck Lever



