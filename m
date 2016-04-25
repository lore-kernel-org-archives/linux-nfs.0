Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f195.google.com ([209.85.217.195]:35833 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932624AbcDYOel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 10:34:41 -0400
Received: by mail-lb0-f195.google.com with SMTP id mx9so9677413lbb.2
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2016 07:34:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160411201733.20911.86904.stgit@manet.1015granger.net>
References: <20160411201733.20911.86904.stgit@manet.1015granger.net>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 25 Apr 2016 16:34:20 +0200
Message-ID: <CAJ75kXZaa66W74BgPHsJ7ND7-9EBzz____91h6Bx1qu=38OzAw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix an LOCK/OPEN race when unlinking an open file
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        anna.schumaker@netapp.com,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Apr 11, 2016 at 10:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
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
> To eliminate this race, serialize delegation return with the
> acquisition of a file lock on the same file. Adopt the same approach
> as is used in the unlock path.
>
> Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>


Is it something which is going to be merged in v4.7?
It also might be a good candidate for stable?

Best regards,
-- 
William
