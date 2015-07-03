Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout3.w1.samsung.com ([210.118.77.13]:56623 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbbGCITi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 04:19:38 -0400
Message-id: <55964593.1070507@samsung.com>
Date: Fri, 03 Jul 2015 11:19:31 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
References: <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
 <20150702082529.GJ17109@ZenIV.linux.org.uk>
 <20150702084208.GK17109@ZenIV.linux.org.uk> <55952C6D.50805@samsung.com>
 <20150702164332.GL17109@ZenIV.linux.org.uk>
 <20150702164926.GN17109@ZenIV.linux.org.uk>
In-reply-to: <20150702164926.GN17109@ZenIV.linux.org.uk>
Content-type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/02/2015 07:49 PM, Al Viro wrote:
> On Thu, Jul 02, 2015 at 05:43:32PM +0100, Al Viro wrote:
>>  	req->tc->tag = tag-1;
>> +	if (req->status != REQ_STATUS_IDLE)
>> +		pr_err("using tag %d with odd status (%d)", tag, req->status);
> 
> Should be tag - 1 here, actually.

So, with this change:

[   81.654695] 9pnet: late delivery, tag 2 already freed
[   81.655186] 9pnet: mismatched reply [tag = 2]
[   85.014795] 9pnet: late delivery, tag 4 already freed
[   85.015753] 9pnet: late delivery, tag 4 already freed
[   85.016473] 9pnet: late delivery, tag 4 already freed
[   87.275842] 9pnet: mismatched reply [tag = 5]
[   88.943223] 9pnet: late delivery, tag 4 already freed
[   88.943790] 9pnet: late delivery, tag 4 already freed
[   88.944320] 9pnet: late delivery, tag 4 already freed
[   88.945050] 9pnet: mismatched reply [tag = 4]
[  105.551220] 9pnet: late delivery, tag 3 already freed
[  105.552065] 9pnet: late delivery, tag 3 already freed
[  114.528467] 9pnet: late delivery, tag 4 already freed
[  164.791295] 9pnet: late delivery, tag 2 already freed
[  164.792156] 9pnet: using tag 2 with odd status (4)
[  164.864398] 9pnet: mismatched reply [tag = 4]
[  166.419993] 9pnet: mismatched reply [tag = 3]
[  174.062625] 9pnet: late delivery, tag 3 already freed
[  174.063121] 9pnet: late delivery, tag 3 already freed
[  174.063637] 9pnet: late delivery, tag 3 already freed
[  174.064018] 9pnet: late delivery, tag 3 already freed
[  174.064547] 9pnet: mismatched reply [tag = 3]
[  175.418729] 9pnet: late delivery, tag 3 already freed
[  177.911727] 9pnet: mismatched reply [tag = 1]
[  235.748520] 9pnet: late delivery, tag 1 already freed
[  235.749595] 9pnet: using tag 1 with odd status (4)
[  243.496782] 9pnet: late delivery, tag 6 already freed
[  243.497697] 9pnet: late delivery, tag 6 already freed
[  243.499079] 9pnet: mismatched reply [tag = 6]
[  243.736388] 9pnet: late delivery, tag 1 already freed
[  243.740019] 9pnet: late delivery, tag 1 already freed
[  248.337712] 9pnet: late delivery, tag 2 already freed
[  249.872950] 9pnet: mismatched reply [tag = 9]
[  252.448858] 9pnet: mismatched reply [tag = 8]
[  252.668878] 9pnet: mismatched reply [tag = 11]
