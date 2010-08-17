Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32983 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0HQRnj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 13:43:39 -0400
Date: Tue, 17 Aug 2010 13:41:34 -0400
To: Andi Kleen <andi@firstfloor.org>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100817174134.GA23176@fieldses.org>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <87aaolwar8.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87aaolwar8.fsf@basil.nowhere.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 04:54:03PM +0200, Andi Kleen wrote:
> "Patrick J. LoPresti" <lopresti@gmail.com> writes:
> 
> >
> > 1) Anybody who cares about file system performance is already using
> > "noatime" or "relatime", which mitigates the hit greatly.
> 
> Consider mtime.
> 
> > If the above patch is too slow for some architectures, how about
> > making it a configuration option?  Call it "CONFIG_1980S_FILE_TICK",
> > have it default to YES on the architectures that care and NO on
> > anything remotely modern and sane.
> >
> > OK that's my proposal.  Bash away.
> 
> I suspect it will be a performance disaster on x86 for VFS intensive
> applications on capable file systems. VFS is very performance
> critical. These checks lurk on unexpected places too, e.g. on /dev
> access.
> 
> Even TSC is much slower than just reading the variable.
> 
> Also you should check if the file system granuality 
> even supports it, it's completely wasted on a ext3 for example.

Agreed, ext3's probably a lost cause here.

> Maybe as a optional sysctl, default to off.

OK, so that leaves us with the race, even on newer filesystems:

	1. File is modified, mtime updated
	2. Client fetches mtime to revalidate cache
	3. File is modified again, mtime updated
	4. Client fetches new mtime to revalidate cache

If step 3 doesn't change the mtime, then step 4 (no matter how much
later it is performed) will return the wrong result, and client
applications will see stale data.

If we want to avoid that race, every modification of file data must
result in the mtime being updated to something different from the last
mtime seen by the client.

(A slight window between data modification and mtime update may be OK,
as long as the update happens eventually, and before the change is
committed to disk--close-to-open semantics mean that NFS clients can
live with not seeing changes until data is written to disk.)

Possible responses:

	- Tell everyone to use NFSv4 (and make sure we have
	  changeattr/i_version working correctly).
	- Use a finer-grained time source.  (I believe you when you say
	  the TSC is too slow, but maybe we should run some tests to
	  make sure.)
	- Increment mtime by a nanosecond when necessary.  
	- ?

--b.
