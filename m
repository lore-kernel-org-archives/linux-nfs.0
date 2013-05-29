Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g4t0017.houston.hp.com ([15.201.24.20]:5298 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116Ab3E2Pza (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2013 11:55:30 -0400
Message-ID: <51A624E2.3000301@hp.com>
Date: Wed, 29 May 2013 11:55:14 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
To: Dave Chinner <david@fromorbit.com>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com> <20130523094201.GA24543@dastard> <519E8B5F.3080905@hp.com> <20130527020903.GR29466@dastard>
In-Reply-To: <20130527020903.GR29466@dastard>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/26/2013 10:09 PM, Dave Chinner wrote:
> On Thu, May 23, 2013 at 05:34:23PM -0400, Waiman Long wrote:
>> On 05/23/2013 05:42 AM, Dave Chinner wrote:
>>>
>>> What was it I said about this patchset when you posted it to speed
>>> up an Oracle benchmark back in february? I'll repeat:
>>>
>>> "Nobody should be doing reverse dentry-to-name lookups in a quantity
>>> sufficient for it to become a performance limiting factor."
>> Thank for the comment, but my point is that it is the d_lock
>> contention is skewing the data about how much spin lock contention
>> had actually happened in the workload and it makes it harder to
>> pinpoint problem areas to look at. This is not about performance, it
>> is about accurate representation of performance data. Ideally, we
>> want the overhead of turning on perf instrumentation to be as low as
>> possible.
> Right. But d_path will never be "low overhead", and as such it
> shouldn't be used by perf.

The d_path() is called by perf_event_mmap_event() which translates VMA 
to its file path for memory segments backed by files. As perf is not 
just for sampling data within the kernel, it can also be used for 
checking access pattern in the user space. As a result, it needs to map 
VMAs back to the backing files to access their symbols information. If 
d_path() is not the right function to call for this purpose, what other 
alternatives do we have?

There may be ways to reduce calls to d_path() by doing some kind of 
caching, but that will certainly increase the complexity of the perf code.

>>> And that makes whatever that tracepoint is doing utterly stupid.
>>> Dumping out full paths in a tracepoint is hardly "low overhead", and
>>> that tracepoint should be stomped on from a great height. Sure,
>>> print the filename straight out of the dentry into a tracepoint,
>>> but repeated calculating the full path (probably for the same set of
>>> dentries) is just a dumb thing to do.
>>>
>>> Anyway, your numbers show that a single AIM7 microbenchmark goes
>>> better under tracing the specific mmap event that uses d_path(), but
>>> the others are on average a little bit slower. That doesn't convince
>>> me that this is worth doing. Indeed, what happens to performance
>>> when you aren't tracing?
>>>
>>> Indeed, have you analysed what makes that
>>> microbenchmark contend so much on the dentry lock while reverse
>>> lookups are occuring? Dentry lock contention does not necessarily
>>> indicate a problem with the dentry locks, and without knowing why
>>> there is contention occuring (esp. compared to the other benchmarks)
>>> we can't really determine if this is a good solution or not...
>> What made it contend so much was the large number of CPUs available
>> in my test system which is a 8-socket Westmere EX machines with 80
>> cores. As perf was collecting data from every core, the threads will
>> unavoidably bump into each other to translate dentries back to the
>> full paths. The current code only allows one CPU in the d_path()
>> critical path. My patch will allow all of them to be in the critical
>> path concurrently.
> Yes, I know *how* contention occurs and what your patch does. I'm
> asking you to explain *why* we need to fix this specific workload,
> and why the tracepoint that calls d_path() actually needs to do
> that.

My patch set consists of 2 different changes. The first one is to avoid 
taking the d_lock lock when updating the reference count in the 
dentries. This particular change also benefit some other workloads that 
are filesystem intensive. One particular example is the short workload 
in the AIM7 benchmark. One of the job type in the short workload is 
"misc_rtns_1" which calls security functions like getpwnam(), 
getpwuid(), getgrgid() a couple of times. These functions open the 
/etc/passwd or /etc/group files, read their content and close the files. 
It is the intensive open/read/close sequence from multiple threads that 
is causing 80%+ contention in the d_lock on a system with large number 
of cores. The MIT's MOSBench paper also outlined dentry reference 
counting as a scalability roadblock for its Apache and Exim tests. So 
that change will certainly help workloads that are dcache reference 
counting intensive.

The second rename_lock change is mainly for reducing the d_path lock 
contention for perf and some other applications that may need to access 
/proc system files like maps or numa_maps frequently. If you think the 
rename_lock change is not worth the effort to just benefit perf, I would 
still like to see the first one go in as it can certainly benefit other 
workload.

> Your numbers indicate that your patchset decreases peformance in the
> common, non-d_path intensive workloads, so why should we add all
> this complexity to optimise a slow path at the expense of
> significant complexity and lower performance in the fast
> path?

My numbers didn't actually indicate a performance regression in other 
common workloads. They just indicate that there wasn't a significant 
changes in performance as + or - a few percentages here and there are 
within the margin of errors for the tests that I used.

>> The upcoming Ivy-Bridge EX can have up to 15 cores per socket. So
>> even a 4-socket machine will have up to 60 cores or 120 virtual CPUs
>> if hyperthreading is turned on.
> I don't see why that matters. I've been dealing with systems much
> larger than that since early 2002, adn the process for delaing with
> lock contention hasn't changed much in the last 10 years. First we
> need to determine what you are doing is something that is sane,
> determining whether there's a simpler fix than changing locking, and
> whether it's actually any faster in the common case we care
> about....

I certainly agree with that. My testing indicated no change in 
performance for the common case, but significant speed-up in some 
scenarios with large number of CPUs.

Regards,
Longman
