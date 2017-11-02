Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22683 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934300AbdKBTqZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Nov 2017 15:46:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFS Force Unmounting
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87bmklv8ls.fsf@notabene.neil.brown.name>
Date: Thu, 2 Nov 2017 15:46:18 -0400
Cc: Jeff Layton <jlayton@kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D32FC586-C351-4810-A4A0-1B2208307A55@oracle.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509460909.4553.37.camel@kernel.org> <8760aux1j5.fsf@notabene.neil.brown.name> <8EB53737-9126-4D26-A22F-D09639BE5130@oracle.com> <87bmklv8ls.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 1, 2017, at 8:15 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Oct 31 2017, Chuck Lever wrote:
> 
>>> On Oct 31, 2017, at 8:53 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>>> Maybe I could just sweep the problem under the carpet and use lazy
>>> unmounts.  That hides some of the problem, but doesn't stop sync(2) from
>>> blocking indefinitely.  And once you have done the lazy unmount, there
>>> is no longer any opportunity to use MNT_FORCE.
>> 
>> IMO a partial answer could be data caching in local files. If
>> the client can't flush, then it can preserve the files until
>> after the umount and reboot (using, say, fscache). Multi-client
>> sharing is still hazardous, but that isn't a very frequent use
>> case.
> 
> What data is it, exactly, that we are worried about here?
> Data that an application has written, but that it hasn't called fsync()
> on?  Do it isn't really all that important.  It might just be scratch
> data.  It might be event logs.  It certainly isn't committed database
> data, or an incoming email message, or data saved by an editor, or
> really anything else important.
> It is data that would be lost if you kicked the powerplug out by
> mistake.
> It is data that we would rather save if we could, but data that is not
> worth bending over backwards to keep a copy of in a non-standard
> location just in case someone really cares.
> 
> That's how I see it anyway.

The assumption here is that any data loss or corruption when a
mount is forcibly removed is strictly the responsibility of
inadequate application design. Fair enough.

One of my concerns (and I suspect Jeff is also worried about this
use case) is what to do when tearing down containers that have
stuck NFS mounts. Here, the host system is not being shut down,
but the guests need to be shutdown cleanly so they can be destroyed.

These containers may be sharing page cache data or a transport
with other users on the host. In this case, we are trying to
avoid a host shutdown to recover the stuck resources, and we
do have the (possibly unnecessary) luxury of having a human
being present to ask what to do to complete the recovery.


--
Chuck Lever



