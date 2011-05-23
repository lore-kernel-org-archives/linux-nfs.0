Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20232 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824Ab1EWUxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 16:53:36 -0400
Message-ID: <4DDAC93A.2020209@panasas.com>
Date: Mon, 23 May 2011 23:53:14 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 23/38] SQUASHME: pnfs-obj: use global device cache
References: <4DD99F9B.2040406@panasas.com> <1306108720-28762-1-git-send-email-bhalevy@panasas.com> <4DD9E805.2020106@panasas.com> <4DDA64C6.2080909@panasas.com>
In-Reply-To: <4DDA64C6.2080909@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/23/2011 04:44 PM, Benny Halevy wrote:
> On 2011-05-23 07:52, Boaz Harrosh wrote:
>> On 05/23/2011 02:58 AM, Benny Halevy wrote:
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>
>> Benny sorry but NACK on the global device cache for now
>>
>> This is to late at this stage. We have decided that first imp will
>> use the private cache and we'll postpone these cleanups for later.
>>
>> All other code was well tested for years, all this is new code, and 
> 
> The file layout is upstream and better be harnessed for other layout
> drivers as well.  If it's inferior to the current objects layout cache
> we should fix and improve the former rather than introducing a new
> implementation.
> 
>> new behaviour that we will not have time to test. I do not like the
> 
> Ideally, the should already be fully tested, but last minute review-
> related changes will always require further testing that needs to be
> taken place during the -rc cycle.  The whole point of having rc's is
> to stabilize the merged code to a point it can be released as a stable
> release.
> 
>> code as it is. Because currently it will release the device on layout_return.
>> Where is the cache? There is much more work to do here!
>>
> 
> Like I said, if there are bugs we should fix them rather introducing
> alternative code that does the same thing.
> 
>> We already said not to do this in this merge why the change of heart?
> 
> We discussed that again on Thursday's conference call which you did not
> attend.  I decided to take a stab at it to see how a unified cache would
> look like and I rather like the outcome..
> 
> Benny
> 

As I suspected this is crashing all over the place. Finally I was  able
to rebase a server on your latest code. (And find out what I was missing).

I'm fighting with it for two hours now. And I don't see the end of it.

Again I'm not at all against this work. I have my own version of this
in my tree. Only against the timing. Your latest code cannot go in now.
It is to new!

What do you want to do now? Postpone pnfs-objects to next Kernel. Or put
in good solid code that was tested and worked for a long time.

I'm not sleeping nights, have worked all through both weekends. Now it is
for nothing. Thanks alot!

Boaz
