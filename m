Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:51916 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaB1W0h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Feb 2014 17:26:37 -0500
MIME-Version: 1.0
In-Reply-To: <CABgxfbHwo13ma=-Xn+S36WwD8LVNLdw6UHztFe8EkCA_=NBenw@mail.gmail.com>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
	<53110287.9000400@talpey.com>
	<CABgxfbHwo13ma=-Xn+S36WwD8LVNLdw6UHztFe8EkCA_=NBenw@mail.gmail.com>
Date: Fri, 28 Feb 2014 14:26:37 -0800
Message-ID: <CABgxfbHg0B02c2zpYdCB4pUZZhhA4aKRuyh4Kx=NE1yAisFLLQ@mail.gmail.com>
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shirley Ma <shirley.ma@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 28, 2014 at 2:20 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> ni i...On Fri, Feb 28, 2014 at 1:41 PM, Tom Talpey <tom@talpey.com> wrote:
>>
>> On 2/26/2014 8:44 AM, Chuck Lever wrote:
>>>
>>> Hi-
>>>
>>> Shirley Ma and I are reviving work on the NFS/RDMA client code base in
>>> the Linux kernel.  So far we've built and run functional tests to determine
>>> what is working and what is broken.
>>>
>>> [snip]
>
>
>>>
>>> ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.
>>> All HCAs support this mode.
>>
>>
>> Not safe is an understatement. It exposes all of client physical
>> memory to the peer, for both read and write. A simple pointer error
>> on the server will silently corrupt the client. This mode was
>> intended only for testing, and in experimental deployments.

(sorry, resend .. previous reply bounced back due to gmail html format)

Please keep "ALLPHYSICAL" for now  - as our embedded system needs it.

Thanks,
Wendy
