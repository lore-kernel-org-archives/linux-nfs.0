Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36471 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbbHDQQP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 12:16:15 -0400
Received: by obnw1 with SMTP id w1so10797473obn.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 09:16:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <A0DBB287-CF36-42D7-8EB3-69327DA48544@oracle.com>
References: <A0DBB287-CF36-42D7-8EB3-69327DA48544@oracle.com>
Date: Tue, 4 Aug 2015 12:16:14 -0400
Message-ID: <CAHQdGtQhjNzZjFtj8sSsGr7uT7ha4hgnVULiJP3ZP20oWCZDJQ@mail.gmail.com>
Subject: Re: TEST_STATEID during lock recovery
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 4, 2015 at 11:04 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi-
>
> One of our testers stumbled on an interesting phenomenon yesterday.
> He purposely caused a client to run out the grace period clock
> during lock recovery on an NFSv4.1 mount. He did this by taking
> thousands of two-byte locks on the same file, and then rebooting
> his server.
>
> The client detects the reboot and starts reclaiming locks. When
> the grace period expires, the server replies NO_GRACE to the
> current LOCK(reclaim). The client responds with RECLAIM_COMPLETE,
> then goes into a hard TEST_STATEID loop.
>
> If I understand the recovery logic, this is trying a TEST_STATEID
> on every lock that was held by the client. The thing is, all the
> locks use the same stateid, since they are on the same file.
>
> So the client is sending TEST_STATEID with the same stateid
> argument over and over and over. All work on the client's mount
> point stops until that loop completes (which it eventually does).
>
> Is there room for some optimization here? Performing one
> TEST_STATEID per lockowner/FH pair is probably better, but I'm
> not clear on how post-grace period recovery is supposed to work.
>

We probably can optimise this, but there hasn't really been too much
manpower put onto it since I'm not aware of any workloads that require
applications to establish lots of lock ranges on the same file.

Cheers
  Trond
