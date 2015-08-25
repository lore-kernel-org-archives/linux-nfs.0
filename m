Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33924 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbbHYREb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 13:04:31 -0400
Received: by obbfr1 with SMTP id fr1so147450257obb.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 10:04:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0BEC962F-39D5-410E-9B75-ED9EE98FFC56@oracle.com>
References: <1440122378-30452-1-git-send-email-trond.myklebust@primarydata.com>
	<0BEC962F-39D5-410E-9B75-ED9EE98FFC56@oracle.com>
Date: Tue, 25 Aug 2015 13:04:30 -0400
Message-ID: <CAHQdGtRsWchQG9ct-Prxy7-PZyw8-jRC6f8fMJvkzxpd58WWpA@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Force a post-op attribute update when holding a delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 12:31 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Aug 20, 2015, at 9:59 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> If the ctime or mtime or change attribute have changed because
>> of an operation we initiated, we should make sure that we force
>> an attribute update. However we do not want to mark the page cache
>> for revalidation.
>
> I've tested your linux-next branch (tip is aebbe9d73169
> ("NFS41/flexfiles: zero out DS write wcc") against Solaris 12
> with write delegation enabled (over RDMA, even!).
>
> I was not able to reproduce the write append failures I saw
> before.
>

Perfect. Thanks for testing!

Trond
