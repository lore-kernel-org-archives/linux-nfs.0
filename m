From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [PATCH 1/1] nfsd41: renew_client() needs to be called with the
 client_mutex held
Date: Thu, 18 Jun 2009 10:51:23 -0700
Message-ID: <C65FCCAB.807A%ricardo.labiaga@netapp.com>
References: <20090618174847.GH9679@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <bhalevy@panasas.com>, <pnfs@linux-nfs.org>,
	<linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15935 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbZFRRvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2009 13:51:23 -0400
In-Reply-To: <20090618174847.GH9679@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/18/09 10:48 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jun 18, 2009 at 10:39:10AM -0700, Labiaga, Ricardo wrote:
>> On 6/18/09 10:31 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> 
>>> On Wed, Jun 17, 2009 at 06:50:45PM -0700, Ricardo Labiaga wrote:
>>>> renew_client() manipulates the client queue for lease renewal.  Need to
>>>> obtain the client_mutex before manipulating it.
>>>> 
>>>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>>>> ---
>>>>  fs/nfsd/nfs4state.c |    2 ++
>>>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>>> 
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index 4cb5d1d..18258d7 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -1537,7 +1537,9 @@ replay_cache:
>>>> * Hold a session reference until done processing the compound:
>>>> * nfsd4_put_session called only if the cstate slot is set.
>>>> */
>>>> + nfs4_lock_state();
>>>> renew_client(session->se_client);
>>>> + nfs4_unlock_state();
>>>> nfsd4_get_session(session);
>>>>  out:
>>>> spin_unlock(&sessionid_lock);
>>> 
>>> We can't take a mutex while handling a spinlock.  (And you should have
>>> gotten warnings about this--not sure what kernel hacking config options
>>> you may need turned on for that.)
>>> 
>> 
>> Ah, OK.  I didn't know that.
> 
> The deadlock:
> 
> Task 1 takes a spinlock.
> Task 1 sleeps on the mutex.
> Task 2 is scheduled in.
> Task 2 requests the same spinlock, spins.
> 
> Now Task 2 is spinning waiting for the spinlock, keeping task 1 from
> getting the cpu back and releaseing the spinlock.  So, no sleeping under
> spinlocks.

Right, thanks.

- ricardo

> 
>>> Possible hack: add a spinlock that for now will just cover the client
>>> lru?
>> 
>> Let me study this some more and see if I can simply drop the sessionid
>> spinlock before renewing the state.
> 
> OK.
> 
> --b.

