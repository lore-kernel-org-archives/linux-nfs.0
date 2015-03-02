Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:45454 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbCBEZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 23:25:01 -0500
Received: by mail-vc0-f180.google.com with SMTP id le20so3338686vcb.11
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2015 20:24:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <A9EDBAEB-B4C1-4C50-9312-108308C283DF@oracle.com>
References: <1425097030-9376-1-git-send-email-trond.myklebust@primarydata.com>
	<A9EDBAEB-B4C1-4C50-9312-108308C283DF@oracle.com>
Date: Sun, 1 Mar 2015 23:24:57 -0500
Message-ID: <CAHQdGtRWPxgA=tf1QY6haGkOJ4KR5oHkb2P2LSsqunmOA7QGxg@mail.gmail.com>
Subject: Re: [PATCH v3 1/8] NFS: Add a helper to set attribute barriers
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 1, 2015 at 9:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Feb 27, 2015, at 11:17 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>
> Tested-by: Chuck Lever <chuck.lever@oracle.com>
>
> I applied this series and the patch that addresses the generic/133
> O_DIRECT regression to stock 3.19.0.
>
> I tested using xfstests with NFSv3 and NFSv4.0, Solaris 11 update 2
> and Linux 3.19 servers. No new test failures (between 2 and 4
> failures out of 55 tests run, which is typical).
>
> I also used dbench and fio to look for performance regressions.
> No regression found so far.
>

Thanks!

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
