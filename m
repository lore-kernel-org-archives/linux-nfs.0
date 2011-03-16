Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12037 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748Ab1CPOOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 10:14:32 -0400
Message-ID: <4D80C5C6.2060003@netapp.com>
Date: Wed, 16 Mar 2011 10:14:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: NeilBrown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
References: <20110316155528.31913c58@notabene.brown> <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
In-Reply-To: <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I guess I misunderstood what to publish test results for?  I know I included numbers on one of the patches (commit 82f2e5472e2304e531c2fa85e457f4a71070044e, copied below)...  I'll find the numbers you're asking about and post them.

-Bryan

commit 82f2e5472e2304e531c2fa85e457f4a71070044e
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Oct 21 16:33:18 2010 -0400

    NFS: Readdir plus in v4
    
    By requsting more attributes during a readdir, we can mimic the readdir plus
    operation that was in NFSv3.
    
    To test, I ran the command `ls -lU --color=none` on directories with various
    numbers of files.  Without readdir plus, I see this:
    
    n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
    --------+-----------+-----------+-----------+-----------+----------
    real    | 0m00.153s | 0m00.589s | 0m05.601s | 0m56.691s | 9m59.128s
    user    | 0m00.007s | 0m00.007s | 0m00.077s | 0m00.703s | 0m06.800s
    sys     | 0m00.010s | 0m00.070s | 0m00.633s | 0m06.423s | 1m10.005s
    access  | 3         | 1         | 1         | 4         | 31
    getattr | 2         | 1         | 1         | 1         | 1
    lookup  | 104       | 1,003     | 10,003    | 100,003   | 1,000,003
    readdir | 2         | 16        | 158       | 1,575     | 15,749
    total   | 111       | 1,021     | 10,163    | 101,583   | 1,015,784
    
    With readdir plus enabled, I see this:
    
    n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
    --------+-----------+-----------+-----------+-----------+----------
    real    | 0m00.115s | 0m00.206s | 0m01.079s | 0m12.521s | 2m07.528s
    user    | 0m00.003s | 0m00.003s | 0m00.040s | 0m00.290s | 0m03.296s
    sys     | 0m00.007s | 0m00.020s | 0m00.120s | 0m01.357s | 0m17.556s
    access  | 3         | 1         | 1         | 1         | 7
    getattr | 2         | 1         | 1         | 1         | 1
    lookup  | 4         | 3         | 3         | 3         | 3
    readdir | 6         | 62        | 630       | 6,300     | 62,993
    total   | 15        | 67        | 635       | 6,305     | 63,004
    
    Readdir plus disabled has about a 16x increase in the number of rpc calls an
    is 4 - 5 times slower on large directories.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>



On 03/16/2011 09:43 AM, Chuck Lever wrote:
> 
> On Mar 16, 2011, at 12:55 AM, NeilBrown wrote:
> 
>> Hi Trond / Bryan et al.
>>
>> Now that openSUSE 11.4 is out I have started getting a few reports
>> of regressions that can be traced to 
>>
>> commit 0715dc632a271fc0fedf3ef4779fe28ac1e53ef4
>> Author: Bryan Schumaker <bjschuma@netapp.com>
>> Date:   Fri Sep 24 18:50:01 2010 -0400
>>
>>    NFS: remove readdir plus limit
>>
>>    We will now use readdir plus even on directories that are very large.
>>
>>    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>
>>
>> This particularly affects users with their home directory over
>> NFS, and with largish maildir mail folders.
>>
>> Where it used to take a smallish number of seconds for (e.g.)
>> xbiff to start up and read through the various directories, it now
>> takes multiple minutes.
>>
>> I can confirm that the slow down is due to readdirplus by mounting the
>> filesystem with nordirplus.
> 
> Back in the dark ages, I discovered that this kind of slowdown was often the result of server slowness.  The problem is that a simple readdir is often a sequential read from physical media.  When you include attribute information, the server has to pick up the inodes, which is a series of small random reads.  It could cause each readdir request to become slower by a factor of 10.  This is a problem on NFS servers where the inode cache is turning over often (small home directory servers, for instance).
> 
> In addition, as more information per file is delivered by READDIRPLUS, each request can hold fewer entries, so more requests and more packets are needed to read a directory.  We hold the request count down now by allowing multi-page directory reads, if the server supports it.
> 
> In any event, applications will see this slow down immediately, but it can also be a significant scalability problem for servers.
> 
>> While I can understand that there are sometime benefits in using
>> readdirplus for very large directories, there are also obviously real
>> costs.  So I think we have to see this patch as a regression that should
>> be reverted.
> 
> It would be useful to understand what it is about these workloads that is causing slow downs.  Is it simply the size of the directory?  Or is there a bug on the server or client that is causing the issue?  Is it a problem only on certain servers or with certain configurations?
> 
>> It would quite possibly make sense to create a tunable (mount option or
>> sysctl I guess) to set the max size for directories to use readdirplus,
>> but I think it really should be an opt-in situation.
> 
> Giving users another knob usually results in higher support costs and confused users.  ;-)
> 
>> [[ It would also be really nice if the change-log for such a significant
>> change contained a little more justification.... :-(   ]]
> 
> I had asked, before this series was included in upstream, for some tests to discover where the knee of the performance curve between readdir and readdirplus was.  Bryan, can you publish the results of those tests?  I had hoped the test results would appear in the patch description to help justify this change.
> 

