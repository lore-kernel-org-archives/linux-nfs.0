From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Tue, 09 Jun 2009 18:32:22 -0400
Message-ID: <4A2EE2F6.7010403@redhat.com>
References: <49C93526.70303@redhat.com>	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com>	 <1243457149.8522.68.camel@heimdal.trondhjem.org>	 <4A1EB09A.8030809@redhat.com>	 <1243892886.4868.74.camel@heimdal.trondhjem.org>	 <4A257167.9090304@redhat.com> <1243980736.4868.314.camel@heimdal.trondhjem.org> <4A268603.4090901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48601 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496AbZFIWc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 18:32:27 -0400
In-Reply-To: <4A268603.4090901@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Staubach wrote:
> Trond Myklebust wrote:
>   
>> On Tue, 2009-06-02 at 14:37 -0400, Peter Staubach wrote:
>>   
>>     
>>> Trond Myklebust wrote:
>>>     
>>>       
>>>> So, how about doing this by modifying balance_dirty_pages() instead?
>>>> Limiting pages on a per-inode basis isn't going to solve the common
>>>> problem of 'ls -l' performance, where you have to stat a whole bunch of
>>>> files, all of which may be dirty. To deal with that case, you really
>>>> need an absolute limit on the number of dirty pages.
>>>>
>>>> Currently, we have only relative limits: a given bdi is allowed a
>>>> maximum percentage value of the total write back cache size... We could
>>>> add a 'max_pages' field, that specifies an absolute limit at which the
>>>> vfs should start writeback.
>>>>       
>>>>         
>>> Interesting thought.  From a high level, it sounds like a good
>>> strategy.  The details start to get a little troubling to me
>>> though.
>>>
>>> First thing that strikes me is that this may result in
>>> suboptimal WRITE requests being issued over the wire.  If the
>>> page quota is filled with many pages from one file and just a
>>> few from another due to timing, we may end up issuing small
>>> over the wire WRITE requests for the one file, even during
>>> normal operations.
>>>     
>>>       
>> balance_dirty_pages() will currently call writeback_inodes() to actually
>> flush out the pages. The latter will again check the super block dirty
>> list to determine candidate files; it doesn't favour the particular file
>> on which we called balance_dirty_pages_ratelimited().
>>
>>   
>>     
>
> It doesn't favor any files.  It runs on all of them.  Without
> some more clever smarts, we end up with small over the wire
> writes, which are to be avoided if at all possible.
>
>   
>> That said, balance_dirty_pages_ratelimited() does take the mapping as an
>> argument. You could, therefore, in theory have it make decisions on a
>> per-mapping basis.
>>
>>   
>>     
>
> I will have to think about this more.  Could you elaborate on
> what you were thinking that we might be able to do?
>
>   
>>> We don't want to flush pages in the page cache until an entire
>>> wsize'd transfer can be constructed for the specific file.
>>> Thus, it seems to me that we still need to track the number of
>>> dirty pages per file.
>>>
>>> We also need to know that those pages are contiguous in the
>>> file.  We can determine, heuristically, whether the pages are
>>> contiguous in the file or not by tracking the access pattern.
>>> For random access, we can assume that the pages are not
>>> contiguous and we can assume that they are contiguous for
>>> sequential access.  This isn't perfect and can be fooled,
>>> but should hold for most applications which access files
>>> sequentially.
>>>
>>> Also, we don't want to proactively flush the cache if the
>>> application is doing random access.  The application may come
>>> back to the page and we could get away with a single WRITE
>>> instead of multiple WRITE requests for the same page.  With
>>> sequential access, we can generally know that it is safe to
>>> proactively flush pages because the application won't be
>>> accessing them again.  Once again, this heuristic is not
>>> foolproof, but holds most of the time.
>>>     
>>>       
>> I'm not sure I follow you here. Why is the random access case any
>> different to the sequential access case? Random writes are obviously a
>> pain to deal with since you cannot predict access patterns. However,
>> AFAICS if we want to provide a faster generic stat(), then we need to
>> deal with random writes too: a gigabyte of data will take even longer to
>> flush out when it is in the form of non-contiguous writes.
>>
>>   
>>     
>
> I think that access patterns are important because we can't solve
> the ls performance problem at the expense of ruining all other
> performance.  During normal operations, ie. without ls running in
> the directory, performance should as close to what exists today
> as possible, or even better.  I think that folks running a
> database in a file would probably not be happy with a tradeoff
> that makes ls run on the database files run faster while making
> the applications which update the database run slower.  We have
> been busy trying to convince people to run databases on top of
> file systems instead of raw partitions and this would hurt.
>
> It would be nice to provide a faster generic stat().  However,
> I don't easily see how to do this and it not clear that we
> actually have to do this.  We do need a faster stat() on files
> that are being sequentially written to.  We have customer
> bugzillas and reports on this already.  The people who tend
> to run applications which use random access on files tend
> to be those who care more about the performance of those
> applications than someone running ls.
>
>
>   
>>> For the ls case, we really want to manage the page cache on a
>>> per-directory of files case.  I don't think that this is going
>>> to happen.  The only directions to go from there are more
>>> coarse, per-bdi, or less coarse, per-file.
>>>     
>>>       
>> Ugh. No...
>>
>>   
>>     
>
> Ugh, indeed.  :-)
>
>   
>>> If we go the per-bdi approach, then we would need to stop
>>> all modifications to the page cache for that particular bdi
>>> during the duration of the ls processing.  Otherwise, as we
>>> stat 1 file at a time, the other files still needing to be
>>> stat'd would just refill the page cache with dirty pages.
>>> We could solve this by setting the max_pages limit to be a
>>> reasonable number to flush per file, but then that would be
>>> too small a limit for the entire file system.
>>>     
>>>       
>> True, but if you have applications writing to all the files in your
>> directory, then 'ls -l' performance is likely to suck anyway. Even if
>> you do have per-file limits, those write-backs to the other files will
>> be competing for RPC slots with the write-backs from the file that is
>> being stat()ed.
>>
>>   
>>     
>
> There is going to be a cost to running ls in a directory which
> contains files which are being actively written to.  I don't
> see how to avoid this, given the architecture of maintaining
> file times by the server and the semantics required.  We can
> strive to limit the cost though.  I think that we can limit
> the cost without affecting normal operations.
>
>   
>>> So, I don't see how to get around managing the page cache on
>>> a per-file basis, at least to some extent, in order to manage
>>> the amount of dirty data that must be flushed.
>>>
>>> It does seem like the right way to do this is via a combination
>>> of per-bdi and per-file support, but I am not sure that we have
>>> the right information at the right levels to achieve this now.
>>>
>>>     Thanx...
>>>
>>>        ps
>>>     
>>>       
>> In the long run, I'd like to see us merge something like the fstatat()
>> patches that were hacked together at the LSF'09 conference.
>> If applications can actually tell the NFS client that they don't care
>> about a/c/mtime accuracy, then we can avoid this whole flushing nonsense
>> altogether. It would suffice to teach 'ls' to start using the
>> AT_NO_TIMES flag that we defined...
>>     
>
> Is someone pursuing those patches which were hacked together
> at LSF'09?  Or, is there a specification or some sort of design
> document for the work?
>
> This would help in some cases.  Using ls without any arguments
> that require file times could certainly be made to run lickety
> split.  However, we would still be stuck with the crowd that
> needed to know file sizes or file times for their own nefarious
> reasons.  It would be easy to dismiss these folks, until one
> becomes a paying support customer with enough clout to demand
> that something be done.  I, myself, even, fall into this
> situation often enough that I wish for the situation to be
> addressed.
>
>     Thanx...
>
>        ps

Hi.

I still need to move this along.

The proposed patch does make things better and as far as I
can tell from my monitoring, does not seem to make things
worse from the user's perspective.  It does restore some
of the support and complexity that was previously removed,
but I don't see how to solve the problem with it.

What'd you think?

    Thanx...

       ps
