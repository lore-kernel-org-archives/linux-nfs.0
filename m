Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:1906 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932388Ab3FQLsU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 07:48:20 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Sandeep Joshi <sanjos100@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: why does nfsd write not use splice
Date: Mon, 17 Jun 2013 11:48:18 +0000
Message-ID: <58D5D77A-B341-4632-A61D-A13462CD40E7@netapp.com>
References: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
 <20130611195140.GA29634@fieldses.org> <51B7DE9C.6080703@talpey.com>
 <20130612153936.GB32569@fieldses.org>
 <CAEfL3KkdjB7bzvnfiDh024kHjCH0e64iH6GK6y+A+bpH3kUgJg@mail.gmail.com>
 <20130612164637.GA6868@fieldses.org>
 <CAEfL3Km7knMAW1Jx_jHZ0OYBMBpUkvbzk2riBE2C=NA9OMvUQw@mail.gmail.com>
 <20130614152215.1f369a4c@tlielax.poochiereds.net>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93F403977@durexcmbx02-prd.hq.netapp.com>
 <20130617070115.34b2fabb@corrin.poochiereds.net>
In-Reply-To: <20130617070115.34b2fabb@corrin.poochiereds.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 17, 2013, at 7:01 AM, Jeff Layton <jlayton@redhat.com>
 wrote:

> On Sat, 15 Jun 2013 05:09:55 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>> owner@vger.kernel.org] On Behalf Of Jeff Layton
>>> Sent: Friday, June 14, 2013 3:22 PM
>>> To: Sandeep Joshi
>>> Cc: J. Bruce Fields; linux-nfs@vger.kernel.org
>>> Subject: Re: why does nfsd write not use splice
>>> 
>>> On Fri, 14 Jun 2013 17:39:12 +0530
>>> Sandeep Joshi <sanjos100@gmail.com> wrote:
>>> 
>>>> On Wed, Jun 12, 2013 at 10:16 PM, J. Bruce Fields <bfields@fieldses.org>
>>> wrote:
>>>>> 
>>>>> On Wed, Jun 12, 2013 at 09:51:09PM +0530, Sandeep Joshi wrote:
>>>>>> Splice can be implemented independent of RDMA.  It is supposed to
>>>>>> transfer pages between two file descriptors.  I found some
>>>>>> postings on lkml from
>>>>>> 2006 where Linus says it is quite possible to splice from a socket
>>>>>> to a file.
>>>>>> 
>>>>>> See the paragraph:
>>>>>> " For filesystems, splice support tends to be really easy (both
>>>>>> read and write). For other things, it depends a bit. But unlike
>>>>>> sendfile(), it really is quite possible to splice _from_ a socket
>>>>>> too, not just _to_ a socket. But no, that case hasn't been written yet."
>>>>>> http://yarchive.net/comp/linux/splice.html
>>>>>> 
>>>>>> Larry McVoy's 1997 proposal for adding splice support to the
>>>>>> kernel can be read at
>>>>>> ftp.tux.org/pub/sites/ftp.bitmover.com/pub/*splice*.*ps*.gz<http:/
>>>>>> /ftp.tux.org/pub/sites/ftp.bitmover.com/pub/splice.ps.gz>
>>>>>> 
>>>>>> Perhaps I should have opened this thread on lkml to determine if
>>>>>> splice from socket to file is still feasible..
>>>>> 
>>>>> Right, the thing is, nfsd reads the rpc request from the socket into
>>>>> its own buffers before it parses it.  If you want to move the data
>>>>> directly out of the network buffers into the page cache, then you
>>>>> have to know at what point the write data starts in the
>>>>> request--which I believe will mean doing the xdr parsing (and gss
>>>>> decryption if necessary) as the request comes in off the wire.
>>>>> 
>>>>> That sounds like a lot of work and even if you have someone willing
>>>>> to do the work they'd also need to justify that it's worth it.
>>>>> 
>>>>> RDMA may have some protocol support that simplifies this, I don't know.
>>>>> 
>>>>> --b.
>>>> 
>>>> Hi Bruce,
>>>> 
>>>>> nfsd reads the rpc request from the socket into its own buffers before it
>>> parses it.
>>>> 
>>>> I am not intimate with the gss code but do you think the
>>>> svc_rqst->rq_pages[] can be spliced ?
>>>> 
>>> 
>>> Probably not in its current form. The problem is one of alignment. You need
>>> to know where the write data actually starts before doing the receive off the
>>> socket, so you can make sure that it ends up in the correct spot in the pages
>>> you're going to splice in.
>>> 
>>> There's also the problem of what to do about WRITE requests that contain
>>> data that isn't page aligned or that's shorter than a page...
>> 
>> Finally, there is the minor problem that the data that is actually received by the socket may be encrypted, or may need to be checksummed (krb5i) _before_ you can apply it to the file. That is not a particularly good fit for splice().
>> 
> 
> Encryption certainly can be a problem, but integrity isn't necessarily
> one.
> 
> Basically the idea would be to receive the data off the socket into a
> set of pages and then splice those into the correct spot in the local
> file. In both the privacy and integrity cases, you just have an extra
> step in between. Privacy *may* mean an extra copy too (though some of
> the crypto routines can decrypt data in place), but handling integrity
> shouldn't.
> 
> The tricky parts (I think) are determining how to lay out the received
> data into the pages you eventually want to splice into the file before
> you receive that data in, and how to deal with it when the WRITE
> doesn't cover an entire page.

Once you've copied the data one time, most of the advantage of splice() is gone, since a copy will then exist in processor cache memory and can be duplicated quickly.

Cheers
  Trond

