From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/24] RPC server support rpcbind v4 plus additional clean ups
Date: Mon, 14 Apr 2008 16:05:36 -0400
Message-ID: <1CBEA184-EBB9-46BD-AD1C-C5C94021949B@oracle.com>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414191412.GN15950@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:62433 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbYDNUGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 16:06:34 -0400
In-Reply-To: <20080414191412.GN15950@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 14, 2008, at 3:14 PM, J. Bruce Fields wrote:
> On Mon, Apr 14, 2008 at 12:26:38PM -0400, Chuck Lever wrote:
>> Hi Bruce, Trond -
>>
>> This patch series provides some minor clean ups, and finishes with an
>> implementation of support for rpcbind version 4 registration.   
>> Version 4
>> support can be entirely disabled in favor of legacy behavior with a  
>> kernel
>> build option, and the default is to use rpcbind version 2 when  
>> registering
>> kernel RPC services.
>>
>> There are 24 patches in this series, but only a few are more than  
>> trivial and
>> hopefully fewer yet are controversial.  I've tried to split these  
>> so that
>> server side and client side changes are in separate patches.
>>
>> It would be helpful for me if they could be considered for 2.6.26.
>
> Thanks.  I've applied 3, 7, 9, and 10, and I'm mostly assuming the
> others are Somebody Else's Problem for now.  Please feel free to  
> correct
> that idea.

At least for now, review of the last 4 patches in the series would be  
useful.  Those go against net/sunrpc/svc.c, which I assume is your  
bailiwick.

Naturally they don't make any sense to apply if the preceding patches  
against net/sunrpc/rpcb_clnt.c aren't accepted.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
