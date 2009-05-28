From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Thu, 28 May 2009 11:41:14 -0400
Message-ID: <4A1EB09A.8030809@redhat.com>
References: <49C93526.70303@redhat.com>	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com> <1243457149.8522.68.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34068 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637AbZE1PlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2009 11:41:19 -0400
In-Reply-To: <1243457149.8522.68.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2009-05-27 at 15:18 -0400, Peter Staubach wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Tue, Mar 24, 2009 at 03:31:50PM -0400, Peter Staubach wrote:
>>>   
>>>       
>>>> Hi.
>>>>
>>>> Attached is a patch which implements some flow control for the
>>>> NFS client to control dirty pages.  The flow control is
>>>> implemented on a per-file basis and causes dirty pages to be
>>>> written out when the client can detect that the application is
>>>> writing in a serial fashion and has dirtied enough pages to
>>>> fill a complete over the wire transfer.
>>>>
>>>> This work was precipitated by working on a situation where a
>>>> server at a customer site was not able to adequately handle
>>>> the behavior of the Linux NFS client.  This particular server
>>>> required that all data to the file written to the file be
>>>> written in a strictly serial fashion.  It also had problems
>>>> handling the Linux NFS client semantic of caching a large
>>>> amount of data and then sending out that data all at once.
>>>>
>>>> The sequential ordering problem was resolved by a previous
>>>> patch which was submitted to the linux-nfs list.  This patch
>>>> addresses the capacity problem.
>>>>
>>>> The problem is resolved by sending WRITE requests much
>>>> earlier in the process of the application writing to the file.
>>>> The client keeps track of the number of dirty pages associated
>>>> with the file and also the last offset of the data being
>>>> written.  When the client detects that a full over the wire
>>>> transfer could be constructed and that the application is
>>>> writing sequentially, then it generates an UNSTABLE write to
>>>> server for the currently dirty data.
>>>>
>>>> The client also keeps track of the number of these WRITE
>>>> requests which have been generated.  It flow controls based
>>>> on a configurable maximum.  This keeps the client from
>>>> completely overwhelming the server.
>>>>
>>>> A nice side effect of the framework is that the issue of
>>>> stat()'ing a file being written can be handled much more
>>>> quickly than before.  The amount of data that must be
>>>> transmitted to the server to satisfy the "latest mtime"
>>>> requirement is limited.  Also, the application writing to
>>>> the file is blocked until the over the wire GETATTR is
>>>> completed.  This allows the GETATTR to be send and the
>>>> response received without competing with the data being
>>>> written.
>>>>
>>>> No performance regressions were seen during informal
>>>> performance testing.
>>>>
>>>> As a side note -- the more natural model of flow control
>>>> would seem to be at the client/server level instead of
>>>> the per-file level.  However, that level was too coarse
>>>> with the particular server that was required to be used
>>>> because its requirements were at the per-file level.
>>>>     
>>>>         
>>> I don't understand what you mean by "its requirements were at the
>>> per-file level".
>>>
>>>   
>>>       
>>>> The new functionality in this patch is controlled via the
>>>> use of the sysctl, nfs_max_outstanding_writes.  It defaults
>>>> to 0, meaning no flow control and the current behaviors.
>>>> Setting it to any non-zero value enables the functionality.
>>>> The value of 16 seems to be a good number and aligns with
>>>> other NFS and RPC tunables.
>>>>
>>>> Lastly, the functionality of starting WRITE requests sooner
>>>> to smooth out the i/o pattern should probably be done by the
>>>> VM subsystem.  I am looking into this, but in the meantime
>>>> and to solve the immediate problem, this support is proposed.
>>>>     
>>>>         
>>> It seems unfortunate if we add a sysctl to work around a problem that
>>> ends up being fixed some other way a version or two later.
>>>
>>> Would be great to have some progress on these problems, though....
>>>
>>> --b.
>>>   
>>>       
>> Hi.
>>
>> I have attached a new testcase which exhibits this particular
>> situation.  One script writes out 6 ~1GB files in parallel,
>> while the other script is simultaneously running an "ls -l"
>> in the directory.
>>
>> When run on a system large enough to store all ~6GB of data,
>> the dd processes basically write(2) all of their data into
>> memory very quickly and then spend most of their time in the
>> close(2) system call flushing the page cache due to the close
>> to open processing.
>>
>> The current flow control support in the NFS client does not work
>> well for this situation.  It was designed to catch the process
>> filling memory and to block it while the page cache flush is
>> being done by the process doing the stat(2).
>>
>> The problem with this approach is that there could potentially be
>> gigabytes of page cache which needs to be flushed to the server
>> during the stat(2) processing.  This blocks the application
>> doing the stat(2) for potentially a very long time, based on the
>> amount of data which was cached, the speed of the network, and
>> the speed of the server.
>>
>> The solution is to limit the amount of data that must be flushed
>> during the stat(2) call.  This can be done by starting i/o when
>> the application has filled enough pages to fill an entire wsize'd
>> transfer and by limiting the number of these transfers which are
>> outstanding so as not to overwhelm the server.
>>
>> -----------
>>
>> While it seems that it would be good to have this done by the
>> VM itself, the current architecture of the VM does not seem to
>> yield itself easily to doing this.  It seems like doing something
>> like a per-file bdi would do the trick, however the system is
>> not scalable to the number of bdi's that that would require.
>>
>> I am open to suggestions for alternate solutions, but in the
>> meantime, this support does seem to address the situation.  In
>> my test environment, it also increases, significantly,
>> performance when sequentially writing large files.  My throughput
>> when dd'ing /dev/sda1 to an NFS mounted file went from ~22MB/s
>> to ~38MB/s.  (I do this for image backups for my laptop.)  Your
>> mileage may vary however.  :-)
>>
>> So, we can consider taking this so that we can address some
>> customer needs?
>>     
>
>
> In the above mail, you are justifying the patch out of concern for
> stat() behaviour, but (unless I'm looking at an outdated version) that
> is clearly not what has driven the design.
> For instance, the call to nfs_wait_for_outstanding_writes() seems to be
> unnecessary to fix the issue of flow control in stat() to which you
> refer above, and is likely to be detrimental to write() performance.
> Also, you have the nfs_is_serial() heuristic, which turns it all off in
> the random writeback case. Again, that seems to have little to do with
> fixing stat().
> I realise that your main motivation is to address the needs of the
> customer in question, but I'm still not convinced that this is the right
> way to do it.
>
>   

Actually, I was able to solve the stat() problem as a side
effect of the original design, but it seemed like additional
reasons for wanting this code integrated.

Yes, part of the architecture is to smooth the WRITE traffic
and to keep from overwhelming the server.  This is what the
nfs_wait_for_outstanding_writes() does.

I could update the changelog to mention that this support is
disabled if the NFS client detects random access to the file.
I added that so that applications such as databases wouldn't
be harmed.  I guess that I just took that sort of thing for
granted and didn't think about it much further.

> To address the actual issue of WRITE request reordering, do we know why
> the NFS client is generating out of order RPCs? Is it just reordering
> within the RPC layer, or is it something else? For instance, I seem to
> recollect that Chris Mason mentioned WB_SYNC_NONE, as being a major
> source of non-linearity when he looked at btrfs. I can imagine that when
> you combine that with the use of the 'range_cyclic' flag in
> writeback_control, then you will get all sorts of "interesting" request
> orders...

This version of the support does not address WRITE request
reordering.  The other changes to system plus the NFS_INO_FLUSHING
support that you added seems to address this in as much as I
don't see out of order WRITE requests anymore.

-----

I am trying to do accomplish two things here.  The first thing
was to smooth the WRITE traffic so that the client would perform
better.  Caching a few gigabytes of data and then flushing it to
the server using a firehose doesn't seem to work very well.  In
a customer situation, I really had a server which could not keep
up with the client.  Something was needed to better match the
client and server bandwidths.

Second, I noticed that the architecture to smooth the WRITE
traffic and do the flow control could be used very nicely to
solve the stat() problem too.  The smoothing of the WRITE
traffic results in fewer dirty cached pages which need to get
flushed to the server during the stat() processing.  This helps
to reduce the latency of the stat() call.  Next, the flow control
aspect can be used to block the application which is writing to
the file while the application.  It happens without adding any
more code to the writing path.

I have spent quite a bit of time trying to measure the performance
impact.  As far as I can see, it varies from significantly better
to no affect.  Some things like dd run much better in my test
network.  Other things like rpmbuild don't appear to be affected.
Compilations tend to be random access to files and are generally
more cpu limited than i/o bound.

-----

I'd be happy to chat about any other ideas for ways to solve
the issues that I need to solve.  At the moment, there is a
customer who is quite interested in getting the stat() problem
resolved.  (He may come to your attention from another
direction as well.)  We've given him a workaround, which may
end up being his solution, but that workaround won't work for
all of the rest of the people who have complained about the
stat() problem.  Adding the locking for i_mutex around the
page flushing did help to ensure that the stat() processing
eventually succeeds, but left some problems with very large
latencies while waiting for large page caches to flush.  Even
on my little 4GB system, those latencies can be 10s of seconds
or more.  This is not generally acceptable by our users.

    Thanx...

       ps
