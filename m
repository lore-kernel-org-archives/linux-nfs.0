From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 15:30:20 -0400
Message-ID: <47D980CC.3020909@citi.umich.edu>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>	 <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net>	 <47D97C5A.6020100@citi.umich.edu> <1205435968.13453.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:8164 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbYCMTaV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 15:30:21 -0400
In-Reply-To: <1205435968.13453.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Thu, 2008-03-13 at 15:11 -0400, Olga Kornievskaia wrote:
>   
>> Trond,
>>
>>     We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
>> machine creds for authenticated callback..
>>     
>
> I'd strongly suggest using a different flag for that purpose. The
> function of RPCAUTH_LOOKUP_ROOTCREDS _today_ is to allow a future
> swap-over-nfs to use root credentials when paging out memory.
>
> That is not the same as machine creds...
>   
I apologize I forgot that I introduced a new flag instead, 
RPCAUTH_USE_MACH_CRED. It should fit with the other flags such as 
RPCAUTH_CRED_NEW in auth.h.


