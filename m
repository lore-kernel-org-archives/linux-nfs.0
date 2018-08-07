Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58953 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727545AbeHGHOM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 03:14:12 -0400
Subject: Re: [LKP] [lkp-robot] [nfsd4] 517dc52baa: fsmark.files_per_sec 32.4%
 improvement
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Ye Xiaolong <xiaolong.ye@intel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        linux-nfs@vger.kernel.org, lkp@01.org,
        LKML <linux-kernel@vger.kernel.org>
References: <20180620065243.GD11011@yexl-desktop>
 <20180620154950.GA28475@parsley.fieldses.org>
 <87va9vu21f.fsf@yhuang-dev.intel.com> <20180716065500.GU27608@yexl-desktop>
 <20180727002225.GF17169@yexl-desktop>
 <20180801114642.GA21500@parsley.fieldses.org>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <63c5dff1-ab1d-3caa-682e-c8b5ff7025d5@intel.com>
Date: Tue, 7 Aug 2018 13:02:16 +0800
MIME-Version: 1.0
In-Reply-To: <20180801114642.GA21500@parsley.fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/2018 07:46 PM, J. Bruce Fields wrote:
> On Fri, Jul 27, 2018 at 08:22:25AM +0800, Ye Xiaolong wrote:
>> On 07/16, Ye Xiaolong wrote:
>>> On 07/04, Huang, Ying wrote:
>>>> "J. Bruce Fields" <bfields@redhat.com> writes:
>>>>
>>>>> Thanks!
>>>>>
>>>>> On Wed, Jun 20, 2018 at 02:52:43PM +0800, kernel test robot wrote:
>>>>>> FYI, we noticed a 32.4% improvement of fsmark.files_per_sec due to commit:
>>>>>>
>>>>>>
>>>>>> commit: 517dc52baa2a508c82f68bbc7219b48169e6b29f ("nfsd4: shortern default lease period")
>>>>>> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git master
>>>>> That doesn't make any sense....
>>>>>
>>>>> OK, I think I see the problem:
>>>>>
>>>>>> in testcase: fsmark
>>>>>> on test machine: 48 threads Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz with 64G memory
>>>>>> with following parameters:
>>>>>>
>>>>>> 	iterations: 1x
>>>>>> 	nr_threads: 1t
>>>>>> 	disk: 1BRD_48G
>>>>>> 	fs: f2fs
>>>>>> 	fs2: nfsv4
>>>>>> 	filesize: 4M
>>>>>> 	test_size: 40G
>>>>>> 	sync_method: fsyncBeforeClose
>>>>>> 	cpufreq_governor: performance
>>>>>>
>>>>>> test-description: The fsmark is a file system benchmark to test synchronous write workloads, for example, mail servers workload.
>>>>>> test-url: https://sourceforge.net/projects/fsmark/
>>>>>>
>>>>>>
>>>>>>
>>>>>> Details are as below:
>>>>>> -------------------------------------------------------------------------------------------------->
>>>>>>
>>>>>>
>>>>>> To reproduce:
>>>>>>
>>>>>>          git clone https://github.com/intel/lkp-tests.git
>>>>>>          cd lkp-tests
>>>>>>          bin/lkp install job.yaml  # job file is attached in this email
>>>>>>          bin/lkp run     job.yaml
>>>>>>
>>>>>> =========================================================================================
>>>>>> compiler/cpufreq_governor/disk/filesize/fs2/fs/iterations/kconfig/nr_threads/rootfs/sync_method/tbox_group/test_size/testcase:
>>>>>>    gcc-7/performance/1BRD_48G/4M/nfsv4/f2fs/1x/x86_64-rhel-7.2/1t/debian-x86_64-2016-08-31.cgz/fsyncBeforeClose/ivb44/40G/fsmark
>>>>>>
>>>>>> commit:
>>>>>>    c2993a1d7d ("nfsd4: extend reclaim period for reclaiming clients")
>>>>>>    517dc52baa ("nfsd4: shortern default lease period")
>>>>>>
>>>>>> c2993a1d7d6687fd 517dc52baa2a508c82f68bbc72
>>>>>> ---------------- --------------------------
>>>>>>           %stddev     %change         %stddev
>>>>>>               \          |                \
>>>>>>       53.60           +32.4%      70.95        fsmark.files_per_sec
>>>>>>      191.89           -24.4%     145.16        fsmark.time.elapsed_time
>>>>>>      191.89           -24.4%     145.16        fsmark.time.elapsed_time.max
>>>>> So what happened is the test took about 45 seconds less.
>>>>>
>>>>> I suspect you're starting the nfs server and then immediately running
>>>>> this test.
>>>> Yes.
>>>>
>>>>> The problem is that if there's a grace period on startup, any open will
>>>>> just hang until the grace period ends.
>>>>>
>>>>> This patch changed the default grace period from 90 seconds to 45, so
>>>>> that would explain the change.
>>>>>
>>>>> In my testing I usually
>>>>>
>>>>> 	start the nfs server
>>>>> 	on the client:
>>>>> 		mount the server
>>>>> 		touch a file
>>>>>
>>>>> When the touch returns, I know any grace period has completed, and then
>>>>> I can run any tests normally.
>>> I've modified our test to touch a file before running the actual workload, then
>>> requeue tests for both commit 517dc52baa and its parent c2993a1d7d, but the
>>> result seems persistent which shows a ~30% improvement of fsmark.files_per_sec.
>>>
>> Any suggestions?	
> You're sure you only start timing after the "touch" returns?
The result is normal after retesting, thank you for helping us improve 
the test.

Best Regards,
Rong, Chen

>
> --b.

