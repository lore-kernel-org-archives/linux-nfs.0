From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: recent failover-by-IP changes
Date: Fri, 2 May 2008 17:40:22 -0400
Message-ID: <20080502214022.GM21918@fieldses.org>
References: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com> <20080502212608.GI21918@fieldses.org> <BBD6EED4-2850-4EA7-A30F-3818BE20E543@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46923 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965235AbYEBVkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 17:40:25 -0400
In-Reply-To: <BBD6EED4-2850-4EA7-A30F-3818BE20E543@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 05:35:47PM -0400, Chuck Lever wrote:
> On May 2, 2008, at 5:26 PM, J. Bruce Fields wrote:
>> On Fri, May 02, 2008 at 04:58:58PM -0400, Chuck Lever wrote:
>>> Hi Wendy-
>>>
>>> Looking at your recent lockd-failover-by-IP changes... I'd like to  
>>> make
>>> sure I understand this logic before I merge it into my NLM IPv6 patch
>>> set.
>>>
>>> In fs/lockd/svcsubs.c:
>>>> static int
>>>> nlmsvc_match_ip(void *datap, struct nlm_host *host)
>>>> {
>>>> 	__be32 *server_addr = datap;
>>>>
>>>> 	return host->h_saddr.sin_addr.s_addr == *server_addr;
>>>
>>> h_saddr is the local host's source address, not the server address,  
>>> and
>>> is used only on multi-interface systems.  Is that what you wanted to
>>> compare, or did you mean ->h_addr?
>>
>> This is server-side code--h_saddr, last I checked, isn't even filled  
>> in
>> on the client side.  So the current host *is* the server.
>
> So this API is requesting that the local host should drop locks?

It's requesting that the server-side lockd drop any locks that it's
holding on behalf of any clients that accessed the server through the
given ip address.

> Okay, 
> that makes sense.  It's not well documented in the code, though.

Could be; suggestions welcomed.

--b.
