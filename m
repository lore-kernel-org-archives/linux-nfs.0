Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:40188 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752166AbdLEXDw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 18:03:52 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
Date: Tue, 5 Dec 2017 21:03:02 -0200 (-02)
To: Matthew Wilcox <willy@infradead.org>
cc: NeilBrown <neilb@suse.com>,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of
 set_groups.
In-Reply-To: <20171205212847.GF26021@bombadil.infradead.org>
Message-ID: <alpine.LFD.2.21.1712052010280.15244@tbecker-rhat>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171130130457.11429-3-thiago.becker@gmail.com> <87mv2ztgix.fsf@notabene.neil.brown.name> <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat> <87efoatfsb.fsf@notabene.neil.brown.name>
 <20171205212847.GF26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 5 Dec 2017, Matthew Wilcox wrote:

> On Tue, Dec 05, 2017 at 07:11:00AM +1100, NeilBrown wrote:
>> As we don't seem to be pursuing this possibility is probably isn't very
>> important, but I'd like to point out that the original fix isn't a true
>> fix.
>> It just sorts a shared group_info early.  This does not stop corruption.
>> Every time a thread calls set_groups() on that group_info it will be
>> sorted again.
>> The sort algorithm used is the heap sort, and a heap sort always moves
>> elements in the array around - it does not leave a sorted array
>> untouched (unlike e.g. the quick sort which doesn't move anything in a
>> sorted array).
>> So it is still possible for two calls to groups_sort() to race.
>> We *need* to move groups_sort() out of set_groups().

Hum, makes sense. I've applied it to the most recent Fedora kernel (that 
uses heapsort) and I didn't see the problem again. I should run a few more 
repetitions to be sure.

> It must be relatively common to sort an already-sorted array.  I wonder
> if something like this patch would be worthwhile?
>
> I have deliberately broken this patch so it can't be applied.  I haven't
> tested it, and for all I know, I got the sign of cmp_func wrong.
>
> diff --git a/lib/sort.c b/lib/sort.c
> index d6b7a202b0b6..2b527fde6dad 100644
> --- a/lib/sort.c
> +++ b/lib/sort.c
> @@ -75,7 +75,14 @@ void sort(void *base, size_t num, size_t size,
> 			swap_func = generic_swap;
> 	}
>
> -       /* heapify */
> +	/* Do not sort an already-sorted array */
> +	for (c = 0; c < (n - size); c += size) {
> +		if (cmp_func(base + c, base + c + size) < 0)
> +			goto heapify;
> +	}
> +	return;
> +
> +heapify:
> 	for ( ; i >= 0; i -= size) {
> 		for (r = i; r * 2 + size < n; r  = c) {
> 			c = r * 2 + size;

The bug happens when two threads enter sort_groups for the same 
group info in parallel, and one thread starts overwriting values 
that another thread may already have "heapified" or sorted.

Thread A                  Thread B
Enter groups_sort
                           Enter groups_sort
.
.
.
Return from groups_sort
                           .
                           .
                           .
                           Return from groups_sort

Wouldn't this patch just make both threads see the structure as unsorted 
and sort them?

Thanks,
trbecker
