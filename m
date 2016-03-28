Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35568 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541AbcC1Qa5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 12:30:57 -0400
Received: by mail-ob0-f174.google.com with SMTP id fp4so103549251obb.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2016 09:30:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160328155114.19702.71714.stgit@manet.1015granger.net>
References: <20160328155114.19702.71714.stgit@manet.1015granger.net>
Date: Mon, 28 Mar 2016 12:30:56 -0400
Message-ID: <CAHQdGtRpaPMvFPK4Q8LGUOf6FhuQbFf6UorWcXYUkAKMyXEO_w@mail.gmail.com>
Subject: Re: [PATCH RFC] xprtrdma: Fix an LOCK/OPEN race when unlinking an
 open file
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Mon, Mar 28, 2016 at 11:51 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> At Connectathon 2016, we found that recent upstream Linux clients
> would occasionally send a LOCK operation with a zero stateid. This
> appeared to happen in close proximity to another thread returning
> a delegation before unlinking the same file while it remained open.
>
> Earlier, the client received a write delegation on this file and
> returned the open stateid. Now, as it is getting ready to unlink the
> file, it returns the write delegation. But there is still an open
> file descriptor on that file, so the client must OPEN the file
> again before it returns the delegation.
>
> Since commit 24311f884189 ('NFSv4: Recovery of recalled read
> delegations is broken'), nfs_open_delegation_recall() clears the
> NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
> racing LOCK on the same inode to be put on the wire before the OPEN
> operation has returned a valid open stateid.
>
> After the OPEN(CLAIM_DELEG_CUR_FH) returns, the client holds both
> a write delegation and a valid open stateid. It is safe to clear
> NFS_DELEGATED_STATE at that point, allowing fresh lock requests
> to go on the wire using the newly acquired open stateid.
>
> I'm not certain of this fix. nfs4_handle_delegation_recall_error()
> is called from both nfs_open_delegation_recall() and
> nfs_lock_delegation_recall(). Is it safe and correct to clear
> NFS_DELEGATED_STATE after success in both of these code paths?
>

I'm not seeing why the subject line is tagged as describing an
xprtrdma issue. Was that intentional?
Secondly, would it perhaps make more sense to have the locking code
simply wait for the outstanding delegation return recovery? Otherwise,
I worry that we are exchanging one timing-specific problem for
another.

Thanks
  Trond
