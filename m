Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50602 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754077AbcJSS2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2016 14:28:45 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: nfsd: managing pages under network I/O
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20161019172611.GA22783@fieldses.org>
Date: Wed, 19 Oct 2016 14:28:40 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CFE1B548-5AC0-451E-BC9D-253395443355@oracle.com>
References: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com> <20161019172611.GA22783@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 19, 2016, at 1:26 PM, bfields@fieldses.org wrote:
> 
> On Wed, Oct 12, 2016 at 01:42:26PM -0400, Chuck Lever wrote:
>> I'm studying the way that the ->recvfrom and ->sendto calls work
>> for RPC-over-RDMA.
>> 
>> The ->sendto path moves pages out of the svc_rqst before posting
>> I/O (RDMA Write and Send). Once the work is posted, ->sendto
>> returns, and looks like svc_rqst is released at that point. The
>> subsequent completion of the Send then releases those moved pages.
>> 
>> I'm wondering if the transport can be simplified: instead of
>> moving pages around, ->sendto could just wait until the Write and
>> Send activity is complete, then return. The upper layer then
>> releases everything.
> 
> I don't understand what problem you're trying to fix.  Is "moving pages
> around" really especially complicated or expensive?

Moving pages is complicated and undocumented, and adds host CPU and
memory costs (loads and stores). There is also a whole lot of page
allocator traffic in this code, and that will be enabling and
disabling interrupts and bottom-halves with some frequency.

The less involvement by the host CPU the better. The current RDMA
transport code documents the RPC-over-RDMA protocol to some extent,
but the need for moving the pages is to the reader's imagination.
