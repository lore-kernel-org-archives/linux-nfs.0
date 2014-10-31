Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:40712 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017AbaJaLbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 07:31:37 -0400
Received: by mail-wg0-f42.google.com with SMTP id k14so6319528wgh.29
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 04:31:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141030090306.GA23917@infradead.org>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
	<1414502171-10319-4-git-send-email-eguan@redhat.com>
	<20141030090306.GA23917@infradead.org>
Date: Fri, 31 Oct 2014 13:31:36 +0200
Message-ID: <CAHQdGtRFMcJGNZvU_V22Xh-3LadD2bYc=TwrkmBVBK81RkWCvw@mail.gmail.com>
Subject: Re: nfs atime semantics, was: Re: [PATCH 3/4] common: skip atime
 related tests on NFS
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 30, 2014 at 11:03 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Oct 28, 2014 at 09:16:10PM +0800, Eryu Guan wrote:
>> >From nfs(5) we can know that atime related mount options have no effect
>> on NFS mounts, so add _require_atime() helper to skip atime tests on NFS
>
> I' like to use this opportunity to start a discussion on NFS atime
> handlign again, which I think is broken.  I think relatime is perfectly
> fine default semantics for NFS, and not supporting it can cause all
> kidns of application breakage.  Supporting normal atime semantics when
> explicity requested is also something NFS shouldn't sneak out of.

If there is no read on the wire, then there is no way to update the
atime without doing an explicit SETATTR. Courtesy of POSIX filesystem
semantics on the server, that means we get a bonus change attribute
and ctime update (no extra charge).

Unless there are new suggestions for how to solve the atime issue that
do not involve introducing this or similar regressions, then the
standing NACK applies.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
