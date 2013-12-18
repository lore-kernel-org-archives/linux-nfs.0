Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f49.google.com ([209.85.213.49]:34903 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701Ab3LRR0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Dec 2013 12:26:21 -0500
Message-ID: <52B1DAB3.6060302@gmail.com>
Date: Wed, 18 Dec 2013 12:26:11 -0500
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Zach Brown <zab@redhat.com>, Christoph Hellwig <hch@infradead.org>
CC: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
References: <1378919210-10372-1-git-send-email-zab@redhat.com> <20131218124126.GA15328@infradead.org> <20131218171044.GK14533@lenny.home.zabbo.net>
In-Reply-To: <20131218171044.GK14533@lenny.home.zabbo.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/18/2013 12:10 PM, Zach Brown wrote:
> On Wed, Dec 18, 2013 at 04:41:26AM -0800, Christoph Hellwig wrote:
>> On Wed, Sep 11, 2013 at 10:06:47AM -0700, Zach Brown wrote:
>>> When I first started on this stuff I followed the lead of previous
>>> work and added a new syscall for the copy operation:
>>>
>>> https://lkml.org/lkml/2013/5/14/618
>>>
>>> Towards the end of that thread Eric Wong asked why we didn't just
>>> extend splice.  I immediately replied with some dumb dismissive
>>> answer.  Once I sat down and looked at it, though, it does make a
>>> lot of sense.  So good job, Eric.  +10 Dummie points for me.
>>>
>>> Extending splice avoids all the noise of adding a new syscall and
>>> naturally falls back to buffered copying as that's what the direct
>>> splice path does for sendfile() today.
>> Given the convolute mess that the splice code already is I'd rather
>> prefer not overloading it even further.
> I agree after trying to weave the copy offloading API into the splice
> interface.  There are also weird cases that we haven't really discussed
> so far (preserving unwritten allocations between the copied files?) that
> would muddy the waters even further.
>
> The further the APIs drift from each other, the more I'm prefering
> giving copy offloading its own clean syscall.  Even if the argument
> types superficially match the splice() ABI.
>
>> We can still fall back to the splice code as a fallback if no option
>> is provided as a last resort, but I think making the splice code handle
>> even more totally different cases is the wrong direction.
> I'm with you.  I'll have another version out sometime after the US
> holiday break.. say in a few weeks?

That'll work for me, I'll update my NFS code once your new patches are out.

Anna

>
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

