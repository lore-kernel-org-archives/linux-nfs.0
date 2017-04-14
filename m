Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26303 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdDNTHY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 15:07:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 09/14] svcrdma: Report Write/Reply chunk overruns
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170414175216.GA8290@fieldses.org>
Date: Fri, 14 Apr 2017 15:07:20 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <809B3E7B-8991-4358-804F-B2D0101723FF@oracle.com>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net> <20170409170641.15073.82788.stgit@klimt.1015granger.net> <20170414155634.GC5362@fieldses.org> <FCC0F429-0799-4416-9A61-ABD19C773AA9@oracle.com> <20170414175216.GA8290@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 14, 2017, at 1:52 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Apr 14, 2017 at 12:10:03PM -0400, Chuck Lever wrote:
>> 
>>> On Apr 14, 2017, at 11:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Sun, Apr 09, 2017 at 01:06:41PM -0400, Chuck Lever wrote:
>>>> Observed at Connectathon 2017.
>>>> 
>>>> If a client has underestimated the size of a Write or Reply chunk,
>>>> the Linux server writes as much payload data as it can, then it
>>>> recognizes there was a problem and closes the connection without
>>>> sending the transport header.
>>> 
>>> Why would the client underestimate?  Is this a client-side bug?
>> 
>> It can be a bug, and the behavior in this case is that the
>> client retransmits indefinitely and deadlocks the transport,
>> because the client's upper layer never sees a reply.
>> 
>> But as you know there are some NFS operations where the client
>> cannot predict in advance how large the reply will be. In
>> particular the upper bound size of an NFSACL GETACL reply or
>> certain NFSv4 GETATTR attributes are not predictable.
> 
> Oh, I'd forgotten about those cases.
> 
>> These
>> I might categorize as protocol bugs.
>> 
>> A client can do its best by posting a very large reply buffer
>> for such operations, but since these situations typically
>> are in practice rare, but NFSv4 GETATTR can be a relatively
>> common operation, clients post a few dozen KB for the reply
>> buffer and call it a day.
>> 
>> In these cases (if they should ever fail IRL), returning an
>> error is polite and allows operation of other RPCs on that
>> transport to continue.
> 
> Got it, thanks.  (I assume this is documented somewhere in the specs?)

I've written about it in rfc5667bis-09. It's a short document,
review comments welcome.


--
Chuck Lever



