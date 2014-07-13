Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:58021 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaGMMFo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 08:05:44 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so2532134qgf.29
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 05:05:43 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 13 Jul 2014 08:05:41 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140713080541.30ecbb51@tlielax.poochiereds.net>
In-Reply-To: <20140713110047.GA28727@infradead.org>
References: <20140713110047.GA28727@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 13 Jul 2014 04:00:47 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Hi Jeff,
> 
> while reviewing some of your patches I've started wondering about
> some v4 locking code.
> 
> In nfsd4_locku we're doing a call to find_any_file to grab a file
> structure for the lock stateid, which nfs4_free_lock_stateid tries to
> close. But what guarantees that we're actually getting the same file
> descriptor back?
> 
> The nfs4_file is shared by and stateid that access a given inode,
> so the first call to find_any_file might return the read/only file
> structure because that's the only one available so far, while
> by the time we unlock we might have a read/write and/or write-only file
> available as well, which find_any_file will return.
> 
> It seems like the lock stateid needs a pointer to the actual file
> locked, and keep a reference to it independent of the nfs4_file, or am I
> missing something?

It is weird, but I don't think it really matters as the filp is only
really used as a way to get to the inode -- it really doesn't matter
which struct file we use there. find_any_file will both take a
reference to and return the file, which is then eventually fput in
filp_close, so there should be no refcount leak or anything.

The weirdness all comes from the vfs-layer file locking interfaces,
many of which take a struct file argument when they really would be
fine with a struct inode. Maybe one of these days we can get around to
cleaning that up.

-- 
Jeff Layton <jlayton@primarydata.com>
