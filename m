Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab0IGQIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 12:08:54 -0400
Date: Tue, 7 Sep 2010 12:08:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Neil Brown <neilb@suse.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH] nfs: support legacy NFS flock behavior via mount
 option
Message-ID: <20100907120847.692bd32e@tlielax.poochiereds.net>
In-Reply-To: <1283869039.4291.16.camel@heimdal.trondhjem.org>
References: <4C84DFA7.7050507@suse.de>
	<1283869039.4291.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 07 Sep 2010 10:17:19 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2010-09-06 at 18:03 +0530, Suresh Jayaraman wrote:
> > NFS clients since 2.6.12 support flock()locks by emulating the
> > BSD-style locks in terms of POSIX byte range locks. So the NFS client
> > does not allow to lock the same file using both flock() and fcntl
> > byte-range locks.
> > 
> > For some Windows applications which seem to use both share mode locks
> > (flock()) and fcntl byte range locks sequentially on the same file,
> > the locking is failing as the lock has already been acquired. i.e. the
> > flock mapped as posix locks collide with actual byte range locks from
> > the same process. The problem was observed on a setup with Windows
> > clients accessing Excel files on a Samba exported share which is
> > originally a NFS mount from a NetApp filer. Since kernels < 2.6.12 does
> > not support flock, what was working (as flock locks were local) in
> > older kernels is not working with newer kernels.
> > 
> > This could be seen as a bug in the implementation of the windows
> > application or a NFS client regression, but that is debatable.
> > In the spirit of not breaking existing setups, this patch adds mount
> > options "flock=local" that enables older flock behavior and
> > "flock=fcntl" that allows the current flock behavior.
> 
> So instead of having a special option for flock only, what say we rather
> introduce an option of the form
> 
>   -olocal_lock=
> 
> which can take the values 'none', 'flock', 'fcntl' (or 'posix'?) and
> 'all'?
> 
> Cheers
>   Trond

Another thought -- we already have "-olock" and "-onolock" and we'll
have to keep them for compatability. Maybe this should be "-oflock" and
"-onoflock"?

-- 
Jeff Layton <jlayton@redhat.com>
