From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 31/33] NFS - fix potential NULL pointer dereference v2
Date: Tue, 22 Apr 2008 10:21:39 -0400
Message-ID: <6919FE8C-0A33-4E5B-91CD-B3E3A9DA8FEE@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204054.14124.59641.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <92D71B7E-B046-4281-B4D4-1F2648DA991E@oracle.com> <1208823685.7767.43.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56822 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbYDVOXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2008 10:23:14 -0400
In-Reply-To: <1208823685.7767.43.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 21, 2008, at 8:21 PM, Trond Myklebust wrote:
> On Mon, 2008-04-21 at 17:13 -0400, Chuck Lever wrote:
>> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
>>> From: Cyrill Gorcunov <gorcunov@gmail.com>
>>>
>>> There is possible NULL pointer dereference if kstr[n]dup failed.
>>
>> The logic in super.c and client.c shouldn't assume  
>> nfs_server.hostname
>> is non-NULL.  Can you say where the NULL dereference might happen?
>
> Sure it does. See for instance all those dereferences of
> nfs_client->cl_hostname. It has never been acceptable to set a null
> hostname.

Whether or not cl_hostname is dereferenced, you need to fix  
export_path too.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
