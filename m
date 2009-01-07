From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 18:01:32 -0600
Message-ID: <20090107000132.GA22261@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <FB1BAB9F-25D4-449F-A66D-D1CC705F3741@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:34202 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbZAGABf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 19:01:35 -0500
In-Reply-To: <FB1BAB9F-25D4-449F-A66D-D1CC705F3741@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Chuck Lever (chuck.lever@oracle.com):
> On Jan 6, 2009, at Jan 6, 2009, 3:02 PM, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc@us.ibm.com):
>>> We can often specify the UTS namespace to use when starting an RPC  
>>> client.
>>> However sometimes no UTS namespace is available (specifically during 
>>> system
>>> shutdown as the last NFS mount in a container is unmounted) so fall
>>> back to the initial UTS namespace.
>>
>> So what happens if we take this patch and do nothing else?
>
> I thought the point of this was to prevent incorrect container nodenames 
> from leaking onto the network.

But define incorrect.  If container B does an nfs mount, container c
is launched with a tree in that mount, container B dies, and container C
umounts it.  Should the umount belong to container B (for having
mounted it), container C (for having umount it), or the init_utsname
(for being the physical host/kernel)?

I get the feeling that consensus on this thread is that init_utsname
is actually the best choice, but OTOH if I have 3 containers on my
host, for apache, mysql, and postfix servers, and each is doing
nfs mounts from a physically remote machine, maybe I care about
having them report separate nodenames?

(that's a question, I really don't know...)

-serge
