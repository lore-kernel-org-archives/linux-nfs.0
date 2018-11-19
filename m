Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A2F6C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:32:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10CBD2080C
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:32:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="li7GDK/W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10CBD2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731042AbeKTH63 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 02:58:29 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:45782 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725898AbeKTH62 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 02:58:28 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAJLSriT171248;
        Mon, 19 Nov 2018 21:32:49 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=usRv1BhEUO6QiWXD6k+sGiRdYIxsG6W/bjP4ezWs95c=;
 b=li7GDK/WUIP1lbum75LQLFdBWMDKxhwGI3kf4zSdbU4+tIXL6mUdg6mx/5WCWd7Ub+l7
 x5nE7wTpPkW2qqM+JxLfQkzisi8hjxn75gqcVzgDnNcJozSJ8iy2fBHyQuRjSlVXqwhK
 PhNhJ4o2JtPdZE3plCJktGQtTibUWzYD8K7J00K0HnBNZeRBtcS4kF+bEZa+uZHVMFJ3
 R0KoI9iWkxXYvC0vF0zmd2/WRDzDNNaN1KjcPLdh90Ml/zM2uT9IW4VQ0fwXOK6T5fda
 YP8dNA2YV3+F6l+g1C2b1Jp7UWc1eYz6/y6o7N+6sIB8ywpvOfIWiCyRP+BNWz0tlf8b Jw== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2ntbmqgdff-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 21:32:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAJLWmYt011436
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 21:32:48 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAJLWlxE029411;
        Mon, 19 Nov 2018 21:32:47 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 19 Nov 2018 13:32:47 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
Date:   Mon, 19 Nov 2018 16:32:46 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <4EE34B64-0BEB-439A-B2A2-D77673D4CF70@oracle.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net>
 <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
 <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
 <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
 <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9082 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811190191
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 19, 2018, at 4:22 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Mon, Nov 19, 2018 at 1:59 PM Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>=20
>>> On Nov 19, 2018, at 1:47 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Mon, Nov 19, 2018 at 1:19 PM Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>>=20
>>>>=20
>>>>=20
>>>>> On Nov 19, 2018, at 1:08 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> On Mon, Nov 19, 2018 at 12:59 PM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>>> On Nov 19, 2018, at 12:47 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>>=20
>>>>>>> On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>=20
>>>>>>>> Place the associated RPC transaction's XID in the upper 32 bits =
of
>>>>>>>> each RDMA segment's rdma_offset field. These bits are currently
>>>>>>>> always zero.
>>>>>>>>=20
>>>>>>>> There are two reasons to do this:
>>>>>>>>=20
>>>>>>>> - The R_key only has 8 bits that are different from =
registration to
>>>>>>>> registration. The XID adds more uniqueness to each RDMA segment =
to
>>>>>>>> reduce the likelihood of a software bug on the server reading =
from
>>>>>>>> or writing into memory it's not supposed to.
>>>>>>>>=20
>>>>>>>> - On-the-wire RDMA Read and Write operations do not otherwise =
carry
>>>>>>>> any identifier that matches them up to an RPC. The XID in the
>>>>>>>> upper 32 bits will act as an eye-catcher in network captures.
>>>>>>>=20
>>>>>>> Is this just an "eye-catcher" or do you have plans to use it in
>>>>>>> wireshark? If the latter, then can we really do that? while a =
linux
>>>>>>> implementation may do that, other (or even possibly future =
linux)
>>>>>>> implementation might not do this. Can we justify changing the
>>>>>>> wireshark logic for it?
>>>>>>=20
>>>>>> No plans to change the wireshark RPC-over-RDMA dissector.
>>>>>> That would only be a valid thing to do if adding the XID
>>>>>> were made part of the RPC-over-RDMA protocol via an RFC.
>>>>>=20
>>>>> Agreed. Can you also help me understand the proposal (as I'm still
>>>>> trying to figure why it is useful).
>>>>>=20
>>>>> You are proposing to modify the RDMA segments's RDMA offset field =
(I
>>>>> see top 6bits are indeed always 0). I don't see how adding that =
helps
>>>>> an RDMA read/write message which does not have an "offset" field =
in it
>>>>> be matched to a particular RPC. I don't believe we have (had) any
>>>>> issues matching the initial RC Send only that contains the =
RDMA_MSG to
>>>>> the RPC.
>>>>=20
>>>> The ULP has access to only the low order 8 bits of the R_key. The
>>>> upper 24 bits are fixed for each MR. So for any given MR, there are
>>>> only 256 unique R_key values. That means the same R_key will appear
>>>> again quickly on the wire.
>>>>=20
>>>> The 64-bit offset field is set by the ULP, and can be essentially
>>>> any arbitrary value. Most kernel ULPs use the iova of the =
registered
>>>> memory. We only need the lower 32 bits for that.
>>>>=20
>>>> The purpose of adding junk to the offset is to make the offset
>>>> unique to that RPC transaction, just like the R_key is. This helps
>>>> make the RDMA segment co-ordinates (handle, length, offset) more
>>>> unique and thus harder to spoof.
>>>=20
>>> Thank you for the explanation that makes sense.
>>>=20
>>>> We could use random numbers in that upper 32 bits, but we have
>>>> something more handy: the RPC's XID.
>>>>=20
>>>> Now when you look at an RDMA Read or Write, the top 32 bits in each
>>>> RDMA segment's offset match the XID of the RPC transaction that the
>>>> RDMA operations go with. This is really a secondary benefit to the
>>>> uniquifying effect above.
>>>=20
>>> I find the wording "no the wire RDMA read or write" misleading. Did
>>> you really mean it as "RDMA read or write" or do you mean "RDMA_MSG"
>>> or do you mean "NFS RDMA read or write"? Because RDMA offset is not =
a
>>> part of the RDMA read/write (first/middle/last) packet. That's what
>>> I'm hanged up on.
>>=20
>> Here's an RDMA Read request in a network capture I had at hand:
>>=20
>> No.     Time               Source                Destination          =
 Protocol Length Info
>>    228 22:31:06.203637    LID: 5                LID: 11               =
InfiniBand 42     RC RDMA Read Request QP=3D0x000240
>>=20
>> Frame 228: 42 bytes on wire (336 bits), 42 bytes captured (336 bits) =
on interface 1
>> Extensible Record Format
>> InfiniBand
>>    Local Route Header
>>    Base Transport Header
>>    RETH - RDMA Extended Transport Header
>>        Virtual Address: 11104011393315758080   <<<<<<
>>        Remote Key: 1879114618
>>        DMA Length: 4015
>>    Invariant CRC: 0xd492a3e1
>>    Variant CRC: 0x8736
>>=20
>> The value of the Virtual Address field is what the RPC-over-RDMA
>> protocol calls the Offset. The Read responses are matched to this
>> request by their message sequence numbers, and this Read request is
>> matched to the RPC Call by the XID in the top 32 bits of the
>> Virtual Address.
>>=20
>> Likewise for an RDMA Write Only request:
>>=20
>>    188 22:31:06.201350    LID: 5                LID: 11               =
InfiniBand 162    RC RDMA Write Only QP=3D0x000240
>>=20
>> Frame 188: 162 bytes on wire (1296 bits), 162 bytes captured (1296 =
bits) on interface 1
>> Extensible Record Format
>> InfiniBand
>>    Local Route Header
>>    Base Transport Header
>>    RETH - RDMA Extended Transport Header
>>        Virtual Address: 10455493047213809920   <<<<<<
>>        Remote Key: 1879115386
>>        DMA Length: 120
>>    Invariant CRC: 0xe2e1b2cd
>>    Variant CRC: 0x676f
>> Data (120 bytes)
>>=20
>> 0000  91 19 5f 87 00 00 00 01 00 00 00 00 00 00 00 00   =
.._.............
>> 0010  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01   =
................
>> 0020  00 00 00 02 00 00 01 ed 00 00 00 02 00 00 04 16   =
................
>> 0030  00 00 00 64 00 00 00 00 00 00 00 28 00 00 00 00   =
...d.......(....
>> 0040  00 00 00 00 00 00 00 00 00 00 00 00 54 9e e5 9d   =
............T...
>> 0050  c6 d3 1a d2 00 00 00 00 00 00 63 1f 5b f2 2e 7a   =
..........c.[..z
>> 0060  0b ae f9 ec 5b f2 2e 7a 0b 53 6c ef 5b f2 2e 7a   =
....[..z.Sl.[..z
>> 0070  0b 53 6c ef 00 00 00 0c                           .Sl.....
>>=20
>>=20
>> I believe RDMA Write First also has an RETH. The sender does not
>> interleave RDMA Writes, so subsequent Middle and Last packets go
>> with this RDMA Write First.
>=20
> Ok I see now where I was confused, in RDMA_MSG in the wireshark it's
> labeled "RDMA offset" and the in the RDMA write first message it's
> labeled "Virtual address". Thank you for explanation.
>=20
> Here's the next question (coming from Jorge)? Is it reasonable to
> assume that top 32bits are always zero? I have an network trace (from
> 4.18-rc2 kernel) where they are not.
>=20
> RPC over RDMA
>    XID: 0xa347cfa2
>    Version: 1
>    Flow Control: 128
>    Message Type: RDMA_MSG (0)
>    Read list (count: 0)
>    Write list (count: 1)
>        Write chunk (1 segment)
>            Write chunk segment count: 1
>            RDMA segment 0
>                RDMA handle: 0x4000076f
>                RDMA length: 65676
>                RDMA offset: 0x0000001049973000
>=20
> I don't believe 0xa347cfa2 can fit?

I've been told by three independent RDMA experts that using the top
32 bits of the offset, even if they are not zero, should be OK to do.
If it doesn't work, it's a device driver bug that needs to be fixed.


--
Chuck Lever



