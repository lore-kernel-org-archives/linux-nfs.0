Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
Date: Tue, 4 Nov 2014 15:38:28 -0500
Message-ID: <CAHQdGtSowoYZDUb6jBbj8Q0g6LeNVHmOCNBoZdDU8CgCZFpOXA@mail.gmail.com>
Subject: Re: Client never uses DATA_SYNC
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On Tue, Nov 4, 2014 at 10:47 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> I have a customer that would like the client to use DATA_SYNC instead of
> FILE_SYNC when writing a file with O_DSYNC.  It looks like the client will
> only use FILE_SYNC since:
>
> 87ed5eb44ad9338b1617 NFS: Don't use DATA_SYNC writes
> http://marc.info/?l=git-commits-head&m=131180398113265&w=2
>
> I've been unable to dig up any other discussion on this, so I think it
> has just been an overlooked point until now.  I'm only starting to
> figure out what would need to change for this, and I thought that while
> I do that I'd ask the list if anyone thinks that serious implementation
> issues might emerge if this were attempted.

I'm not aware of any servers that make a real distinction between
FILE_SYNC and DATA_SYNC. Has anybody done any performance measurements
to show that it is worth the effort?

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
