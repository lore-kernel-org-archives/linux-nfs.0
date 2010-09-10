Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754661Ab0IJBo5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 21:44:57 -0400
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make
 locks local
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
In-Reply-To: <4C896A59.8060903@suse.de>
References: <4C893746.6090202@suse.de>
	 <20100909162037.20c4ebec@tlielax.poochiereds.net>
	 <4C896A59.8060903@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 09 Sep 2010 21:44:23 -0400
Message-ID: <1284083063.2764.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 04:44 +0530, Suresh Jayaraman wrote:
> On 09/10/2010 01:50 AM, Jeff Layton wrote:
> > On Fri, 10 Sep 2010 01:06:38 +0530
> > Suresh Jayaraman <sjayaraman@suse.de> wrote:
> > 
> >> NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
> >> locks. Due to this, some windows applications which seem to use both flock
> >> (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
> >> the same file, can't lock as they falsely assume the file is already locked.
> >> The problem was reported on a setup with windows clients accessing excel files
> >> on a Samba exported share which is originally a NFS mount from a NetApp filer.
> >>
> >> Older NFS clients (< 2.6.12) did not see this problem as flock locks were
> >> considered local. To support legacy flock behavior, this patch adds a mount
> >> option "-olocal_lock=" which can take the following values:
> >>
> >>    'none'  		- Neither flock locks or fcntl/posix locks are local
> >>    'flock'/'posix' 	- flock locks are local
> > 	^^^^^^^
> > "posix" ought to be synonymous with "fcntl". "flock" was a BSD-ism.
> 
> Oops, that should have read 'fcntl/posix' (though the code gets it right)..

Yup. It appears to be a changelog bug...

> > It may be better to keep it simple though and drop either "posix" or
> > "fcntl". No need to add unneeded synonyms on a brand new mount option.
> 
> Makes sense.. Trond: which one is more consistent?

I have a slight preference for 'posix'. fcntl is an extensible
interface, which currently supports at least two different types of lock
('posix' and 'lease').

> >>    'fcntl' 		- fcntl locks are local
> >>    'all'		- Both flock locks and fcntl/posix locks are local
> >>

Cheers
  Trond
