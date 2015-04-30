Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46468 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbD3RkX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 13:40:23 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH, RFC] backchannel overflows
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
Date: Thu, 30 Apr 2015 13:41:02 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
References: <20150428202157.GA23972@infradead.org> <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com> <20150429151404.GA12936@infradead.org> <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com> <20150429173454.GA23284@fieldses.org> <20150430062558.GA25660@infradead.org> <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com> <20150430143731.GA22038@infradead.org> <CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com> <20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 30, 2015, at 11:11 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Apr 30, 2015, at 11:01 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>>> 
>>> 
>>> On Thu, Apr 30, 2015 at 10:37 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>> On Thu, Apr 30, 2015 at 10:34:02AM -0400, Chuck Lever wrote:
>>>> I?ve been discussing the possibility of adding more session slots on
>>>> the Linux NFS client with jlayton. We think it would be straightforward,
>>>> once the workqueue-based NFSD patches are in, to make the backchannel
>>>> service into a workqueue. Then it would be a simple matter to increase
>>>> the number of session slots.
>>>> 
>>>> We haven?t discussed what would be needed on the server side of this
>>>> equation, but sounds like it has some deeper problems if it is not
>>>> obeying the session slot table limits advertised by the client.
>>> 
>>> No, the client isn't obeying it's own slot limits
>>> 
>>> The problem is when the client responds to a callback it still
>>> holds a references on rpc_rqst for a while.  If the server
>>> sends the next callback fast enough to hit that race window the
>>> client incorrectly rejects it.  Note that we never even get
>>> to the nfs code that check the slot id in this case, it's low-level
>>> sunrpc code that is the problem.
>> 
>> We can add dynamic allocation of a new slot as part of the backchannel reply transmit workload. That way we close the race without opening for violation of session limits.
> 
> I’ll have to think about how that would affect RPC/RDMA backchannel.
> Transport resources are allocated when the transport is created, and
> can’t be dynamically added. (It certainly wouldn’t be a problem to
> overprovision, as Christoph has done here).

We discussed this briefly during the Linux NFS town hall meeting.
I agree using dynamic slot allocation for TCP is fine, and RPC/RDMA
can use simple overprovisioning.

This way the upper layer (NFSv4.1 client) doesn’t have to be aware of
limitations in the RPC layer mechanism.

Trond may have an additional concern that I didn’t capture.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



