Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:46575 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbeDQON6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 10:13:58 -0400
Received: by mail-vk0-f53.google.com with SMTP id v205so11855049vkv.13
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 07:13:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFf2dkQYhbeULgKMuN8i=hJ4JUnETwN6x0J786H_fWVLg@mail.gmail.com>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org> <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <20180417134141.GB10291@parsley.fieldses.org> <FE7DF381-A335-4827-94AB-1DEBF5FCEB05@netapp.com>
 <20180417135708.GD10291@parsley.fieldses.org> <CAN-5tyFf2dkQYhbeULgKMuN8i=hJ4JUnETwN6x0J786H_fWVLg@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 17 Apr 2018 10:13:56 -0400
Message-ID: <CAN-5tyE7srmScvToz-GvWrksQb1JcwYnby+RobD6E8zPLi7AyA@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Jorge Mora <Jorge.Mora@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 10:08 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Tue, Apr 17, 2018 at 9:57 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>> On Tue, Apr 17, 2018 at 09:43:45AM -0400, Olga Kornievskaia wrote:
>>> > On Apr 17, 2018, at 9:41 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> > Christoph said: "I'd like to see numbers for actual, real use cases."
>>> > Yes, I'd love to see that too.
>>> >
>>> > Is it possible to get testing on real hardware that we'd expect people
>>> > to use, with sufficient details about the setup that someone else could
>>> > reproduce the results?
>>>
>>> The numbers we presented was on real hardware. If you have any more questions regarding the setup please ask.
>>
>> Argh, sorry, you had to remind me once already:
>>
>>         https://www.ietf.org/mail-archive/web/nfsv4/current/msg15379.html
>
> Yes that was for the "inter" copy.
>
> Besides those numbers, Jorge also did the numbers for the asynchronous
> vs synchronous intra copy. Are you interested in them as well?
> Hopefully Jorge still has them.

I found this in my emails. There is degradation for file size <- 8MB
and increase in performance for >16MB

Here are the numbers (each test is run 10 times and the average is displayed):

/home/mora/logs/nfstest_ssc_20171015174051.log:    synchronous SSC
/home/mora/logs/nfstest_ssc_20171015171323.log:    asynchronous SSC

Performance degradation for file size <= 8MB:

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
1KB file: 0.162018680573 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
1KB file: 0.636984395981 seconds
                                                         74.56%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
2KB file: 0.177096033096 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
2KB file: 0.583548688889 seconds
                                                         69.65%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
4KB file: 0.207866406441 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
4KB file: 0.782712388039 seconds
                                                         73.44%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
8KB file: 0.201173448563 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
8KB file: 0.692702102661 seconds
                                                         70.96%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
16KB file: 0.216166472435 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
16KB file: 0.56289691925 seconds
                                                         61.60%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
32KB file: 0.185425901413 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
32KB file: 0.65691485405 seconds
                                                         71.77%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
64KB file: 0.238445782661 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
64KB file: 0.525265741348 seconds
                                                         54.60%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
128KB file: 0.166219258308 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
128KB file: 0.69602959156 seconds
                                                         76.12%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
256KB file: 0.192826724052 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
256KB file: 0.556627941132 seconds
                                                         65.36%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
512KB file: 0.230020523071 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
512KB file: 0.496951031685 seconds
                                                         53.71%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
1MB file: 0.225317955017 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
1MB file: 0.50447602272 seconds
                                                         55.34%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
2MB file: 0.233719205856 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
2MB file: 0.570275163651 seconds
                                                         59.02%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
4MB file: 0.285868096352 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
4MB file: 0.656079149246 seconds
                                                         56.43%
performance degradation by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
8MB file: 0.509396600723 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
8MB file: 0.696055078506 seconds
                                                         26.82%
performance degradation by async


Performance improvement for file size >= 16MB:

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
16MB file: 0.960887002945 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
16MB file: 0.817601919174 seconds
                                                         14.91%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
32MB file: 1.58274662495 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
32MB file: 1.24578406811 seconds
                                                         21.29%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
64MB file: 2.54690010548 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
64MB file: 1.58639280796 seconds
                                                         37.71%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
128MB file: 4.2253510952 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
128MB file: 2.58433949947 seconds
                                                         38.84%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
256MB file: 7.71305201054 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
256MB file: 4.43859291077 seconds
                                                         42.45%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
512MB file: 14.6445164919 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
512MB file: 8.18448216915 seconds
                                                         44.11%
performance improvement by async

/home/mora/logs/nfstest_ssc_20171015174051.log:    PASS: SSC copy of
1GB file: 28.7619983673 seconds
/home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
1GB file: 16.1399238825 seconds
                                                         43.88%
performance improvement by async
