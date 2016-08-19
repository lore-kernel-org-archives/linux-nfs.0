Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33776 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754418AbcHSPvz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 11:51:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: WARN_ON added to rpc_create()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160819154721.GF32329@fieldses.org>
Date: Fri, 19 Aug 2016 11:51:13 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7E7D9CD1-1B68-4C2B-AF29-DFB7ED6CA4EE@oracle.com>
References: <42D0C152-58F9-4467-B86D-2A7A25544CE4@oracle.com> <20160803174724.GA5993@fieldses.org> <5E7D6A55-B7F3-411D-A74B-E8BCE04BCF02@oracle.com> <20160818215611.GA25052@fieldses.org> <FA0D14B1-EC11-4345-887C-413EDC403E3A@oracle.com> <20160819145055.GA2956@parsley.fieldses.org> <77E4C34B-23DD-4F3B-9D6B-670855E3DC0D@oracle.com> <20160819154721.GF32329@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 19, 2016, at 11:47 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Aug 19, 2016 at 11:06:16AM -0400, Chuck Lever wrote:
>>> On Aug 19, 2016, at 10:50 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> On Thu, Aug 18, 2016 at 06:11:43PM -0400, Chuck Lever wrote:
>>>> OK, but why is a WARN_ON needed here? Why not return -EINVAL,
>>>> for example (once you've corrected BC_TCP -> BC) ?
>>> 
>>> Well, it would be a programming bug, so I'd want a WARN_ON or similar
>>> somewhere, I don't care particularly where it is if you see a better way
>>> to organize things.
>> 
>> The way it works now, the WARN_ON fires, but the logic goes ahead
>> and creates the transport anyway.
>> 
>> If this is a programming bug, it should fail and return an error,
> 
> I haven't been following that rule.
> 
> Once upon a time, I would have put a BUG() there.  Then Linus pointed
> out that sometimes a BUG() can bork the machine badly enough that the
> backtrace doesn't even make it to the logs, rendering it useless.  (And
> I believe that could be the case here since this is running as a work
> item.)  So, I stick a WARN() there instead and don't worry much what
> happens afterwards.

I still don't understand. If you would have put a BUG here, then
why does this logic continue and create the transport anyway?

Well, it's a nit, so I'll drop it.


>> If it is not a programming bug (which is implied by the fact that
>> a transport is created anyway) then no WARN_ON is needed.
> 
> So, could we just agree that WARN_ON means "there's a programming
> error", regardless of what happens next?  Backtraces should never happen
> on a working kernel.
> 
> And then ignore the following code path.  Unless it's something that's
> obviously going to immediately oops in the warned case, in which case if
> we really want the warning then we should return if that looks safer.
> 
> But I don't have really strong feelings about this case, the warning may
> be academic since setup_callback_client() makes this look obviously
> impossible, so if you want to reorganize this somehow, feel free to give
> it a shot.

Right, it's that obviously impossible part that made me wonder why
there was a warning here in the first place.

OK, the fix is to do BC_TCP -> BC and put our pencils down. Do you
want me to send you a patch, or do you plan to take care of it?

--
Chuck Lever



