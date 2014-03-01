Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:48187 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753205AbaCAVet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Mar 2014 16:34:49 -0500
Message-ID: <53125125.9010709@opengridcomputing.com>
Date: Sat, 01 Mar 2014 15:29:09 -0600
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Wendy Cheng <s.wendy.cheng@gmail.com>
CC: Tom Talpey <tom@talpey.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shirley Ma <shirley.ma@oracle.com>
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com> <53110287.9000400@talpey.com> <CABgxfbHwo13ma=-Xn+S36WwD8LVNLdw6UHztFe8EkCA_=NBenw@mail.gmail.com> <CABgxfbHg0B02c2zpYdCB4pUZZhhA4aKRuyh4Kx=NE1yAisFLLQ@mail.gmail.com> <B83B4DA6-E9CF-4DF3-9227-5EF9B4D25F4D@oracle.com>
In-Reply-To: <B83B4DA6-E9CF-4DF3-9227-5EF9B4D25F4D@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

I have a patch for the server side that simplifies the memory registration 
and fixes a bug where the server ignores the FRMR hardware limits. This 
bug is actually upstream now.

I have been sitting on it because it's a big patch and will require a lot 
of testing/review to get it upstream. This is Just an FYI in case there is 
someone on your team who has the bandwidth to take this work and finish it up.

Thanks,
Tom

On 2/28/14 8:59 PM, Chuck Lever wrote:
> Hi Wendy-
>
> On Feb 28, 2014, at 5:26 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>
>> On Fri, Feb 28, 2014 at 2:20 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>>> ni i...On Fri, Feb 28, 2014 at 1:41 PM, Tom Talpey <tom@talpey.com> wrote:
>>>> On 2/26/2014 8:44 AM, Chuck Lever wrote:
>>>>> Hi-
>>>>>
>>>>> Shirley Ma and I are reviving work on the NFS/RDMA client code base in
>>>>> the Linux kernel.  So far we've built and run functional tests to determine
>>>>> what is working and what is broken.
>>>>>
>>>>> [snip]
>>>
>>>>> ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.
>>>>> All HCAs support this mode.
>>>>
>>>> Not safe is an understatement. It exposes all of client physical
>>>> memory to the peer, for both read and write. A simple pointer error
>>>> on the server will silently corrupt the client. This mode was
>>>> intended only for testing, and in experimental deployments.
>> (sorry, resend .. previous reply bounced back due to gmail html format)
>>
>> Please keep "ALLPHYSICAL" for now  - as our embedded system needs it.
> This is just the client side.  Confirming that you still need support for the ALLPHYSICAL memory registration mode in the NFS/RDMA client.
>
> Do you have plans to move to a mode that is less risky?  If not, can we depend on you to perform regular testing with ALLPHYSICAL as we update the client code?  Do you have any bug fixes you’d like to merge upstream?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

