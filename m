Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:48453 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab2CYO7k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Mar 2012 10:59:40 -0400
Received: by vbbff1 with SMTP id ff1so2193546vbb.19
        for <linux-nfs@vger.kernel.org>; Sun, 25 Mar 2012 07:59:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332362855.12332.11.camel@lade.trondhjem.org>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
	<1332359184-1887-13-git-send-email-andros@netapp.com>
	<1332362855.12332.11.camel@lade.trondhjem.org>
Date: Sun, 25 Mar 2012 10:59:39 -0400
Message-ID: <CADnza44q6-JYdGmRh9CLdGcTOTB93O8nCcJO-inAYm__wi72ug@mail.gmail.com>
Subject: Re: [PATCH Version 2 12/12] NFSv4.1 have filelayout_initiate_commit
 return void
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 4:47 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-03-21 at 15:46 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> The return is ignored.
>
> Yes, but should it be? See the discussion between Fred and myself on the
> list yesterday. I still don't see why we should report some errors and
> ignore others...
>
>

I'll come back to this in a day or two, but let me note the following
problem with nfs_commit_inode, pnfs, and error reporting.

Consider nfs_wb_page, which causes a FLUSH_SYNC nfs_commit_inode.

Pre-pnfs, nfs_commit_inode either returned an error, or sent the
COMMIT.  Even if the page didn't make it into the "to be cleaned" list
due to the INT_MAX restriction, the COMMIT was sent and on non-eror
return it was safe to assume that the page data was on disk.

But with pnfs (and commit to DS), lets say that the writes are
distributed between 2 data servers.  On a non-error return from
nfs_commit_inode there is now no guarantee that a COMMIT will go to
the DS hosting the page.  That is solely due to the INT_MAX
restriction.  It of course gets even worse with the current
filelayout_commit_pagelist if an alloc fails.


Fred
