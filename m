Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:39597 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755077AbbCRVDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 17:03:35 -0400
Message-ID: <5509E824.6070006@Netapp.com>
Date: Wed, 18 Mar 2015 17:03:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
References: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com> <1426540688-32095-4-git-send-email-Anna.Schumaker@Netapp.com> <20150317195633.GC29843@fieldses.org> <20150317200738.GD29843@fieldses.org> <20150317213654.GE29843@fieldses.org> <5509C0FD.70309@Netapp.com> <20150318185545.GF8818@fieldses.org> <5509E27C.3080004@Netapp.com> <20150318205554.GA10716@fieldses.org>
In-Reply-To: <20150318205554.GA10716@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/18/2015 04:55 PM, J. Bruce Fields wrote:
> On Wed, Mar 18, 2015 at 04:39:24PM -0400, Anna Schumaker wrote:
>> On 03/18/2015 02:55 PM, J. Bruce Fields wrote:
>>> On Wed, Mar 18, 2015 at 02:16:29PM -0400, Anna Schumaker wrote:
>>>> On 03/17/2015 05:36 PM, J. Bruce Fields wrote:
>>>>> On Tue, Mar 17, 2015 at 04:07:38PM -0400, J. Bruce Fields wrote:
>>>>>> On Tue, Mar 17, 2015 at 03:56:33PM -0400, J. Bruce Fields wrote:
>>>>>>> On Mon, Mar 16, 2015 at 05:18:08PM -0400, Anna Schumaker wrote:
>>>>>>>> This patch implements sending an array of segments back to the client.
>>>>>>>> Clients should be prepared to handle multiple segment reads to make this
>>>>>>>> useful.  We try to splice the first data segment into the XDR result,
>>>>>>>> and remaining segments are encoded directly.
>>>>>>>
>>>>>>> I'm still interested in what would happen if we started with an
>>>>>>> implementation like:
>>>>>>>
>>>>>>> 	- if the entire requested range falls within a hole, return that
>>>>>>> 	  single hole.
>>>>>>> 	- otherwise, just treat the thing as one big data segment.
>>>>>>>
>>>>>>> That would provide a benefit in the case there are large-ish holes
>>>>>>> with minimal impact otherwise.
>>>>>>>
>>>>>>> (Though patches for full support are still useful even if only for
>>>>>>> client-testing purposes.)
>>>>>>
>>>>>> Also, looks like
>>>>>>
>>>>>> 	xvs_io -c "fiemap -v" <file>
>>>>>>
>>>>>> will give hole sizes for a given <file>.  (Thanks, esandeen.)  Running
>>>>>> that on a few of my test vm images shows a fair number of large
>>>>>> (hundreds of megs) files, which suggests identifying only >=rwsize holes
>>>>>> might still be useful.
>>>>>
>>>>> Just for fun.... I wrote the following test program and ran it on my
>>>>> collection of testing vm's.  Some looked like this:
>>>>>
>>>>> 	f21-1.qcow2
>>>>> 	144784 -rw-------. 1 qemu qemu 8591507456 Mar 16 10:13 f21-1.qcow2
>>>>> 	total hole bytes:      8443252736 (98%)
>>>>> 	in aligned 1MB chunks: 8428453888 (98%)
>>>>>
>>>>> So, basically, read_plus would save transferring most of the data even
>>>>> when only handling 1MB holes.
>>>>>
>>>>> But some looked like this:
>>>>>
>>>>> 	501524 -rw-------. 1 qemu qemu 8589934592 May 20  2014 rhel6-1-1.img
>>>>> 	total hole bytes:      8077516800 (94%)
>>>>> 	in aligned 1MB chunks: 0 (0%)
>>>>>
>>>>> So the READ_PLUS that caught every hole might save a lot, the one that
>>>>> only caught 1MB holes wouldn't help at all.
>>>>>
>>>>> And there were lots of examples in between those two extremes.
>>>>
>>>> I tested with three different 512 MB files:  100% data, 100% hole, and alternating every megabyte.  The results were surprising:
>>>>
>>>>       |  v4.1  |  v4.2
>>>> -----------------------
>>>> data  | 0.685s |  0.714s
>>>> hole  | 0.485s | 15.547s
>>>> mixed |	1.283s |  0.448
>>>>
>>>> >From what I can tell, the 100% hole case takes so long because of the
>>>>> SEEK_DATA call in nfsd4_encode_read_plus_hole().  I took this out to
>>>>> trick the function into thinking that the entire file was already a
>>>>> hole, and runtime dropped to the levels of v4.1 and v4.2.
>>>
>>> Wait, that 15s is due to just one SEEK_DATA?
>>
>> The server is returning a larger hole than the client can read at once, so there are several SEEK_DATA calls made to verify that there are no data segments before the end of the file.
>>
>>>
>>>> I wonder
>>>>> if this is filesystem dependent?  My server is exporting ext4.
>>>
>>> Sounds like just a bug.  I've been doing lots of lseek(.,.,SEEK_DATA) on
>>> both ext4 and xfs without seeing anything that weird.
>>
>> It looks like something weird on ext4.  I switched my exported filesystem to xfs:
> 
> Huh.  Maybe we should report a bug....
> 
>>
>>       |  v4.1  |  v4.2
>> ------+--------+-------
>> data  | 0.764s | 1.343s
> 
> That's too bad.  Non-sparse files are surely still a common case and
> we'd like to not see a slowdown there....  I wonder if we can figure out
> where it's coming from?

That's a good question, especially since the 1G file didn't double this time.  Maybe a VM quirk?


> 
>> hole  | 0.572s | 0.205s
>> mixed |	0.634s | 0.472s
>>
>>
>> I bumped up the test to 1G files:
>>
>>       |  v4.1  |  v4.2
>> ------+--------+-------
>> data  | 1.578s | 1.743s
>> hole  | 1.241s | 0.443s
>> mixed |	1.884s | 0.913s
>>
>> Let me know if I should test anything larger!
> 
> The other thing I'd be interested in would be a "mixed" case that
> alternates every 4k.  That will test the worst case where we we do a 1MB
> read and get back only a 4k hole.  Aligned 1MB holes are somewhat of a
> best case.

I probably won't get a chance to test this until I'm back from my vacation, but I'll keep the suggestion in mind!

Anna
> 
> --b.
> 

