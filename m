Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:49677 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaENSVZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 May 2014 14:21:25 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <009601cf6f9f$f47b2cb0$dd718610$@opengridcomputing.com>
Date: Wed, 14 May 2014 14:21:07 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Tom Tucker <tom@opengridcomputing.com>
Message-Id: <639CE8CC-46CE-4EC9-A97B-2F146BA045C4@gmail.com>
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174632.18208.28160.stgit@build.ogc.int> <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com> <00f901cf6eeb$2ff1f630$8fd5e290$@opengridcomputing.com> <3DAF95F3-22D5-4FC5-8C98-5A440E54DC2F@gmail.com> <53737D15.6020902@opengridcomputing.com> <2AEECADA-4A40-4BF2-866E-7F178D016DDE@gmail.com> <009601cf6f9f$f47b2cb0$dd718610$@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 14, 2014, at 2:11 PM, Steve Wise <swise@opengridcomputing.com> wrote:

> 
>>> 
>>>> If you print ch_count, it is 2 for NFS WRITEs from a Linux client,
>>>> no matter how large the write payload is. Therefore I think the check
>>>> as it is written is not particularly useful.
>>> 
>>> Why are there 2?
>> 
>> The first chunk lists the pages the server is to read, and the second
>> chunk has the zero pad for XDR alignment.
>> 
>> If pad optimization is enabled on the client, there is just 1 chunk in
>> the RPC's Read list.
>> 
> 
> So the code as it stands violates the RFC by sending 2 chunks?

The Linux client is non-compliant because it sends two chunks. A compliant server ignores the second chunk, so this is functionally harmless (but a waste of resources).

The Linux server is non-compliant because it _requires_ the XDR pad chunk. A compliant client (eg. Linux with pad optimization enabled) does not interoperate with it.

> And if I change the server
> to only consume 1, then everything unaligned will break?

If you change the server to consume only the first chunk, but do not also make it deal with XDR padding as recommended in chapter 3 of RFC 5666, then WRITEs with a length that is not a multiple of four will fail. SYMLINKs with a large payload will also have this problem.

--
Chuck Lever
chucklever@gmail.com



