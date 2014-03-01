Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:47945 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbaCAROe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Mar 2014 12:14:34 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140301110022.417eb088@tlielax.poochiereds.net>
Date: Sat, 1 Mar 2014 12:14:24 -0500
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>, Tom Talpey <tom@talpey.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shirley Ma <shirley.ma@oracle.com>
Message-Id: <C30CED5A-0242-4ADE-83F3-386C157DD197@oracle.com>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com> <53110287.9000400@talpey.com> <CABgxfbHwo13ma=-Xn+S36WwD8LVNLdw6UHztFe8EkCA_=NBenw@mail.gmail.com> <CABgxfbHg0B02c2zpYdCB4pUZZhhA4aKRuyh4Kx=NE1yAisFLLQ@mail.gmail.com> <B83B4DA6-E9CF-4DF3-9227-5EF9B4D25F4D@oracle.com> <20140301110022.417eb088@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 1, 2014, at 11:00 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 28 Feb 2014 21:59:00 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Wendy-
>> 
>> On Feb 28, 2014, at 5:26 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>> 
>>> On Fri, Feb 28, 2014 at 2:20 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>>>> ni i...On Fri, Feb 28, 2014 at 1:41 PM, Tom Talpey <tom@talpey.com> wrote:
>>>>> 
>>>>> On 2/26/2014 8:44 AM, Chuck Lever wrote:
>>>>>> 
>>>>>> Hi-
>>>>>> 
>>>>>> Shirley Ma and I are reviving work on the NFS/RDMA client code base in
>>>>>> the Linux kernel.  So far we've built and run functional tests to determine
>>>>>> what is working and what is broken.
>>>>>> 
>>>>>> [snip]
>>>> 
>>>> 
>>>>>> 
>>>>>> ALLPHYSICAL - Usually fast, but not safe as it exposes client memory.
>>>>>> All HCAs support this mode.
>>>>> 
>>>>> 
>>>>> Not safe is an understatement. It exposes all of client physical
>>>>> memory to the peer, for both read and write. A simple pointer error
>>>>> on the server will silently corrupt the client. This mode was
>>>>> intended only for testing, and in experimental deployments.
>>> 
>>> (sorry, resend .. previous reply bounced back due to gmail html format)
>>> 
>>> Please keep "ALLPHYSICAL" for now  - as our embedded system needs it.
>> 
>> This is just the client side.  Confirming that you still need support for the ALLPHYSICAL memory registration mode in the NFS/RDMA client.
>> 
>> Do you have plans to move to a mode that is less risky?  If not, can we depend on you to perform regular testing with ALLPHYSICAL as we update the client code?  Do you have any bug fixes you’d like to merge upstream?
>> 
> 
> Also, given that ALLPHYSICAL isn't considered safe, we should at the
> very least require some sort of explicit opt-in before allowing it to be
> used. Perhaps either a Kconfig option, or maybe a runtime switch like a
> module parm?

Well, there is already an opt-in: /proc/sys/sunrpc/rdma_memreg_strategy
selects the default registration mode. Currently FRMR is always used
unless the HCA doesn’t support it.

If we need to keep ALLPHYSICAL, the least thing I would want to do is
remove the logic in rpcrdma_ia_open() that switches to ALLPHYSICAL if
the mode selected by rdma_memreg_strategy isn’t supported by the HCA.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



