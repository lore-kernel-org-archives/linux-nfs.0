Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g4t0016.houston.hp.com ([15.201.24.19]:24756 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966083Ab3E2Uk5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2013 16:40:57 -0400
Message-ID: <51A667D4.4050301@hp.com>
Date: Wed, 29 May 2013 16:40:52 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Dave Chinner <david@fromorbit.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>,
        Ian Kent <raven@themaw.net>, Sage Weil <sage@inktank.com>,
        Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com> <20130523094201.GA24543@dastard> <519E8B5F.3080905@hp.com> <20130527020903.GR29466@dastard> <51A624E2.3000301@hp.com> <20130529184640.GA3243@fieldses.org>
In-Reply-To: <20130529184640.GA3243@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/29/2013 02:46 PM, J. Bruce Fields wrote:
> On Wed, May 29, 2013 at 11:55:14AM -0400, Waiman Long wrote:
>> On 05/26/2013 10:09 PM, Dave Chinner wrote:
>>> On Thu, May 23, 2013 at 05:34:23PM -0400, Waiman Long wrote:
>>>> On 05/23/2013 05:42 AM, Dave Chinner wrote:
>>>>> What was it I said about this patchset when you posted it to speed
>>>>> up an Oracle benchmark back in february? I'll repeat:
>>>>>
>>>>> "Nobody should be doing reverse dentry-to-name lookups in a quantity
>>>>> sufficient for it to become a performance limiting factor."
>>>> Thank for the comment, but my point is that it is the d_lock
>>>> contention is skewing the data about how much spin lock contention
>>>> had actually happened in the workload and it makes it harder to
>>>> pinpoint problem areas to look at. This is not about performance, it
>>>> is about accurate representation of performance data. Ideally, we
>>>> want the overhead of turning on perf instrumentation to be as low as
>>>> possible.
>>> Right. But d_path will never be "low overhead", and as such it
>>> shouldn't be used by perf.
>> The d_path() is called by perf_event_mmap_event() which translates
>> VMA to its file path for memory segments backed by files. As perf is
>> not just for sampling data within the kernel, it can also be used
>> for checking access pattern in the user space. As a result, it needs
>> to map VMAs back to the backing files to access their symbols
>> information. If d_path() is not the right function to call for this
>> purpose, what other alternatives do we have?
> As Dave said before, is the last path component sufficient?  Or how
> about an inode number?

I don't think so. The user-space perf command will need the full 
pathname to locate the binaries and read their debug information. Just 
returning the last path component or the inode number will not cut it.

Regards,
Longman
