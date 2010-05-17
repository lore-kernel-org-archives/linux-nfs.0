From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in	reverse
 order
Date: Mon, 17 May 2010 17:24:39 +0300
Message-ID: <4BF151A7.1070003@panasas.com>
References: <20100510033610.GA5443@MDS-78.localdomain> <4BEA4ED3.3010702@panasas.com> <20100512202811.GA9296@fieldses.org> <20100517135341.GA30737@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org, iisaman@netapp.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37398 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab0EQOYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 10:24:46 -0400
Received: by wyb39 with SMTP id 39so477647wyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 07:24:44 -0700 (PDT)
In-Reply-To: <20100517135341.GA30737@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2010 04:53 PM, J. Bruce Fields wrote:
> On Wed, May 12, 2010 at 04:28:12PM -0400, bfields wrote:
>> On Wed, May 12, 2010 at 09:46:43AM +0300, Benny Halevy wrote:
>>> On May. 10, 2010, 6:36 +0300, Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
>>>> Optimize for sequencial write. Layout infos and tags are organized by
>>>> file offset. When appending data to a file whole list will be examined,
>>>> which introduce notable performance decrease.
>>>
>>> Looks good to me.
>>>
>>> Fred, can you please double check?
>>
>> I don't know if Fred's still up for reviewing block stuff?
>>
>> I've been trying to keep up with at least some minimal testing, but not
>> as well as I'd like.
>>
>> The one thing I've noticed is that the connectathon general test has
>> started failing right at the start with an IO error.  The last good
>> version I tested was b5c09c21, which was based on 33-rc6.  The earliest
>> bad version I tested was 419312ada, based on 34-rc2.  A quick look at
>> network traces from the two traces didn't turn up anything obvious.  I
>> haven't had the chance yet to look closer.
> 
> As of the latest (6666f47d), in my tests the client is falling back on
> IO to the MDS and doing no block IO at all.  b5c09c21 still works, so
> the problem isn't due to a change in the server I'm testing against.  I
> haven't investigated any more closely.
> 

You might be hitting the .commit bug, no? Still no fix. I'm using a work
around for objects. I'm not sure how it affects blocks. I think you should
see that the very first IO goes through layout driver then the IO is redone
through MDS, for each node. Even though write/read returned success because
commit returns NOT_ATTEMPTED. But I might be totally off.

Boaz
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

