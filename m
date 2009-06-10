From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Wed, 10 Jun 2009 15:43:44 -0400
Message-ID: <4A300CF0.6030002@redhat.com>
References: <49C93526.70303@redhat.com>	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com>	 <1243457149.8522.68.camel@heimdal.trondhjem.org>	 <4A1EB09A.8030809@redhat.com>	 <1243892886.4868.74.camel@heimdal.trondhjem.org>	 <4A257167.9090304@redhat.com>	 <1243980736.4868.314.camel@heimdal.trondhjem.org>	 <4A268603.4090901@redhat.com>  <4A2EE2F6.7010403@redhat.com> <1244588719.24750.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40234 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757149AbZFJTns (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2009 15:43:48 -0400
In-Reply-To: <1244588719.24750.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-06-09 at 18:32 -0400, Peter Staubach wrote:
>   
>> I still need to move this along.
>>     
>
> Sorry, it has been a long week at home (state championships,
> graduation...).
>
>   

State championships?  How did they go?

> I did promise to send a dump of the state of the fstatat() stuff from
> LSF (see attachments).
>
>   

Thanx!  Seems fairly straightforward.

> As for the patch you posted, I did have comments that haven't really
> been addressed. As I said, I certainly don't see the need to have
> write() wait for writebacks to complete. I also don't accept that we
> need to treat random writes as fundamentally different from serial
> writes.
>   

Sorry about not addressing your comments adequately.

Are you refering to nfs_wait_for_outstanding_writes() or
do you see someplace else that write() is waiting for
writebacks to complete?  Perhaps I should have named it
nfs_wait_for_too_many_outstanding_writes()?  :-)

That certainly was not the intention.  The intention was to
have the pages gathered and then the over the wire stuff
handled asynchronously.  If this is not true, then I need to
do some more work.

A goal of this work is attempt to better match the bandwidth
offered by the network/server/storage with the rate at which
applications can create dirty pages.  It is not good for the
application to get too far ahead and too many pages dirtied.
This leads to the current problem with stat() as well as
much nastier out of memory conditions.  If the system is not
capable of cleaning more than N GB/second, then it doesn't
make sense for applications to dirty more than that same
N GB/second.  In the end, they won't be able to do that
anyway, so why tie up the memory, possibly causing problems?

I see random access as being different than sequential
mostly due to the expectations that the different style
applications have.  Applications which access a file
sequentially typically do not expect to access the pages
again after either reading them or writing them.  This does
not mean that we should toss them from the page cache, but
it does mean that we can start writing them because the
chances of the application returning to update the contents
of the pages is minimized and the pages will need to get
written anyway.

Applications that use random access patterns are much more
likely to return to existing pages and modify them for a
second time.  Proactively writing these pages means that
multiple over the wire writes would be required when fewer
over the wire writes would have actually been required by
waiting.

> I'm currently inclining towards adding a switch to turn off strict posix
> behaviour. There weren't too many people asking for it earlier, and
> there aren't that many applications out there that are sensitive to the
> exact mtime. Samba and backup applications are the major exceptions to
> that rule, but you don't really run those on top of NFS clients if you
> can avoid it...

While I think that this switch is an okay idea and will help
some applications which get modified to use it, it does not
help existing applications or applications which want the
correct time values and also reasonable performance.

I believe that we can help all applications by reviewing the
page cache handling architecture for the NFS client.

    Thanx...

       ps
