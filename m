Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:46016 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752411AbeCXQA2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Mar 2018 12:00:28 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v1 1/2] NFSD: Clean up write argument XDR decoders
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180324024047.GW4288@fieldses.org>
Date: Sat, 24 Mar 2018 12:00:23 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C825F167-12BE-4072-84CB-FDA705E91BEE@oracle.com>
References: <20180319184647.10100.25736.stgit@klimt.1015granger.net>
 <20180319185648.10100.94060.stgit@klimt.1015granger.net>
 <20180323213253.GV4288@fieldses.org>
 <4061A951-7FA1-4E85-9D04-3AB5F20A4A7B@oracle.com>
 <ABCD8B94-C1F9-475A-AF45-53DC3EAEFB41@oracle.com>
 <20180324024047.GW4288@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 23, 2018, at 10:40 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> On Fri, Mar 23, 2018 at 06:37:51PM -0400, Chuck Lever wrote:
>>=20
>>=20
>>> On Mar 23, 2018, at 5:55 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>>=20
>>>=20
>>>> On Mar 23, 2018, at 5:32 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>>>>=20
>>>> If I understand correctly, in the v4 case you change the way the =
page
>>>> data is passed by using rq_arg.pages instead of a list of pages for =
each
>>>> write.
>>>>=20
>>>> I don't think that handles the case of compounds with multiple =
writes.
>>>>=20
>>>> If all the writes are contained in a page, then you may be OK, =
since the
>>>> wr_head iovec is all the information you need to pass the write =
data
>>>> from the xdr code to the proc code.
>>>>=20
>>>> But if there are multiple larger writes, you also need to know =
where the
>>>> page data is.  You're depending on rq_arg.pages for that, but =
there's
>>>> only one of those per compound.
>>>=20
>>> I thought we were going to handle that case by chaining xdr_bufs--
>>> one per NFSv4 WRITE operation. There has to be some structured way
>>> to pass distinct write payloads up to the NFS server, otherwise
>>> direct placement is impossible.
>>=20
>> Thinking on this a little more, I think you are saying the new shared
>> decoder is adequate for NFSv2 and NFSv3, but not for NFSv4.
>=20
> Yes, it would be a regression in the v4 case, but not in the v2 or v3
> cases.
>=20
>> Would you
>> accept a patch that kept the NFSv2 and NFSv3 parts of this patch, but
>> dropped the NFSv4-related hunks?
>>=20
>> Likewise for the symlink decoder patch?
>=20
> I'll have to take another look, but, could be.

Thanks!


>> And we can still use a transport call-out in the XDR decoders, just =
as
>> we have discussed. (I think I've misremembered our discussion about
>> chaining xdr_bufs).
>=20
> Maybe chaining xdr bufs would make sense, I haven't thought about it.

Hrm, chaining was your idea, actually. But chaining is not needed if
each RDMA Read is driven by the WRITE XDR decoder. For each WRITE
payload, the XDR decoder could pass an array of pages, a starting
offset into the first page, and a byte count, and the transport could
fill those pages.

A detail would be how to handle both a request that provides only an
unstructured byte stream and a request where the payloads are
structured. TCP provides only the former, RPC/RDMA can provide either
type.


> But we currently handle multiple IOs per compound without chaining xdr
> bufs.

Yes, by using one or more pull-up data copies. The point is we want to
enable the transport hardware to place each payload where no =
re-alignment
is needed.


--
Chuck Lever



