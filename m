Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63029 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856Ab1ECUOB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 16:14:01 -0400
Subject: Re: [RFC 0/1] SUNRPC: dynamic rpc_slot allocator for TCP
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <0C6F7F78-D506-463B-B4B7-D780BA9FA95F@oracle.com>
Date: Tue, 3 May 2011 16:13:59 -0400
Cc: trond.myklebust@netapp.com, jlayton@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <A5ED05D7-9EA2-46C0-A27E-63FFA39BC024@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com> <0C6F7F78-D506-463B-B4B7-D780BA9FA95F@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 3, 2011, at 4:06 PM, Chuck Lever wrote:

> Hi-
> 
> On May 2, 2011, at 9:40 PM, andros@netapp.com wrote:
> 
>> I would appreciate comments on this patch. I've done a small amount of testing
>> where I've set the /proc/sys/sunrpc/tcp_slot_table_entries to 2, and watched
>> the dynamic allocator increase it to 3. I have a 10G test system being
>> configured.
> 
> For TCP transports, then, the effective slot table size varies between the tcp_slot_table_entries setting and the estimated number of RPCs that can fit in the TCP window?  

Yes.

> What happens when the TCP window shrinks such that fewer RPCs can fit than are allowed by the tcp_slot_table_entries setting?

We don't shrink the rpc_slot table size. The idea being that if the TCP hits size X then shrinks to size X-n, there is a good chance that it will get back to size X. In the worst case, this is still better than a hard configured 'to large' slot table size.

> 
> Have you done performance testing with loopback mounts (ie server and client on the same machine, mounting over the "lo" interface)?  As I recall this was the test case that Trond found worked poorly when we boosted the tcp_slot_table_entries setting to default to a 64 entry slot table.

No, not yet. I'll add this to the planned testing.  So having way too many default rpc_slots is bad? I could test by starting with a default of 2 slots and seeing how many are needed.

-->Andy

> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 

