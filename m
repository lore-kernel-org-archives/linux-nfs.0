Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6B1EC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 20:21:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8DAC7217D7
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 20:21:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727682AbfBRUVq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 15:21:46 -0500
Received: from fieldses.org ([173.255.197.46]:45360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727400AbfBRUVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 15:21:46 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 12C1E1E29; Mon, 18 Feb 2019 15:21:46 -0500 (EST)
Date:   Mon, 18 Feb 2019 15:21:46 -0500
To:     Gefei Li <gefeili.2013@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: linux NFS client lock file cannot get a expected response
Message-ID: <20190218202146.GB5879@fieldses.org>
References: <CANidX5RGLuvdS82TpxuagUsA4DmUochDv2AwX7rwHdD-q+Khbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CANidX5RGLuvdS82TpxuagUsA4DmUochDv2AwX7rwHdD-q+Khbg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 18, 2019 at 05:11:47PM +0800, Gefei Li wrote:
> I am recently testing linux nfs lock with NFS share from a WinServer
> 2016. I tried to write a file which has already been locked with fcntl
> exclusively, but the response of `write` syscall is neither
> `Permission denied`, nor successfully written with file content
> changed. Here is several experiments I did:
> 
> The first shell runs c program, calling `fcntl` to lock file
> exclusively “fcntl(fd, F_SETLKW, &fl)”
> 
> 2.1 The second shell tried to open with flag O_RDWR, and write a
> buffer to the same file, write returned the correct bytes written, but
> the file content remained unchanged.

You're checking the file content on the server somehow?

The client's caching the write--it returns success to the application
and then sends the actual write to the server later.  Anything else will
hurt performance of a lot of applications.

> 2.2 The second shell tried to open with flag O_RDWR|O_SYNC, write the
> same buffer to the same file, write operation returned EAGAIN
> 2.3 The same operation on ext4 file system gives me a expected
> behavior the same as advisory lock expressed, successfully written
> with file content changed.
> 
> I reviewed NFS 4.1 protocol(RFC 5661 page 185), the nfs server can
> determine whether byte range lock can be either mandatory or advisory,
> but I think 2.1 and 2.2 gives me some unexpected behavior as these
> two.. What’s your idea about this? Can you give me some tips to work
> this out?

There's also section 10.3.3, but I never understood how that was really
supposed to work.  It recommends the client turn off caching when
mandatory locking is in effect--but the only way it gives the client
that mandatory locking is in effect is by seeing an ERR_LOCKED reply to
a READ or WRITE, and by that point it's too late.

Anyway, as far as I can tell the results you report are what's expected.

--b.

> Looking forward for your reply. Thanks in advance!
> 
> BTW, my linux kernel version is 4.15.0, linux release: ubuntu 16.04
> from Azure marketplace, my nfs-common version is
> "nfs-common/xenial-updates,now 1:1.2.8-9ubuntu12.1 amd64" from ubuntu
> apt repo.
> 
> Thanks,
> Gefei
