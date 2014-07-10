Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31316 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbaGJUoK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 16:44:10 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for NFSv2/3
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140710194349.GD26561@fieldses.org>
Date: Thu, 10 Jul 2014 16:43:54 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Message-Id: <F8AD3320-C653-4713-965F-FE52FF0D49CA@oracle.com>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net> <20140710174435.3734.69638.stgit@klimt.1015granger.net> <20140710181944.GB26561@fieldses.org> <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com> <20140710184948.GC26561@fieldses.org> <B89AB7AC-32E1-4944-9287-73958A569A8E@oracle.com> <20140710194349.GD26561@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ Correcting Steve’s e-mail address ]

On Jul 10, 2014, at 3:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Thu, Jul 10, 2014 at 03:07:34PM -0400, Chuck Lever wrote:
>> Hi Bruce-
>> 
>> On Jul 10, 2014, at 2:49 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> On Thu, Jul 10, 2014 at 02:24:57PM -0400, Chuck Lever wrote:
>>>> 
>>>> On Jul 10, 2014, at 2:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> 
>>>>> On Thu, Jul 10, 2014 at 01:44:35PM -0400, Chuck Lever wrote:
>>>>>> The server should comply with RFC 5667,
>>>>> 
>>>>> Where's the relevant language?  (I took a quick look but didn't see it.)
>>>> 
>>>> Sorry, I listed the wrong RFC when I wrote the description of bug 246.
>>>> It’s actually RFC 5666, section 3.7.
>>> 
>>> Thanks.
>>> 
>>>>> So I think you just want to drop the round-up of len, not the whole
>>>>> check.
>>>> 
>>>> I’ll try that, thanks!
>> 
>> Works-as-expected.
>> 
>>> Actually, I'd really rather this get fixed up in the rpc layer.  The
>>> padding is really required for correct xdr.
>> 
>> How so?
> 
> Well, to be spec-lawyerly, rfc 1832 3.9 defines opaque data as including
> the zero-padding; a sequence of bytes isn't legal xdr if it just ends
> early.

RFC 5666 section 3.7 is talking about the situation where the transport
is dealing with a list of pages, not a stream of bytes. Each item in
the list is handled by a separate RDMA READ. The client isn’t sending
the payload bytes, the server is pulling them from the client, so the
integrity of the RPC request stream isn’t affected if the server doesn’t
read the last item in the page list, for example.

> 
>> All of NFSv4 and all other NFSv3 operations work as expected
>> without that padding present. There doesn’t seem to be any operational
>> dependency on the presence of padding. Help?
> 
> I can believe that the code deals with it now, I just wonder if this
> check may not be the only case where someone writing xdr code expects
> total length to be a multiple of four.

The exception in section 3.7 applies only to lists of pages. RPC/RDMA
requests sent via RDMA SEND or via RDMA_NOMSG would terminate the XDR
byte stream normally with a zero pad. Since such requests are transmitted
via a single RDMA operation anyway, there’s scant benefit to leaving
off the pad bytes.

Thus this exception applies only to the two operations that RFC 5667
allows to use a read chunk (page list): WRITE and SYMLINK.

> The drc code also depends on the length being right, see
> nfsd_cache_csum.  I don't know whether that will cause a practical
> problem in this case.

OK. DRC is kind of important, at least for NFSv3.

> (What about the krb5i case?)
> 
>>> The fact that RDMA doesn't
>>> require those zeroes to be literally transmitted across the network
>>> sounds like a transport-level detail that should be hidden from the xdr
>>> code.
>> 
>> The best I can think of is adding a false page array entry to the
>> xdr_buf if the last incoming page is short by a few bytes.
> 
> The padding just gets added to the end of whichever page the write ended
> on, and you only use another page if you run out of space, right?

I think I misunderstood the RDMA READ code. No extra page should be
necessary.

The only question I have is whether the receive pages are set up so
that the server itself can write pad bytes into them before the RDMA
READs are done.

> I don't know, if that's a huge pain then I guess we can live with this.

Fixing svcrdma was my first approach, but I abandoned it once I
realized that NFSv3 WRITE was the only failing case.

I think the sanity check you pointed out is strictly satisfied by
testing against the unaligned number of bytes. Is there a strong
reason to do the extra math for that check during each WRITE?

Otherwise, I’m looking closely at hooking this up in the transport
as you suggested, for comparison.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



