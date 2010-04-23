From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs4 hangs when rpcbind is not reachable
Date: Fri, 23 Apr 2010 11:32:02 -0400
Message-ID: <4BD1BD72.2030709@oracle.com>
References: <alpine.LSU.2.01.1004231717180.2242@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23957 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab0DWPcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 11:32:55 -0400
In-Reply-To: <alpine.LSU.2.01.1004231717180.2242-SHaQjdQMGhDmsUXKMKRlFA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2010 11:18 AM, Jan Engelhardt wrote:
> Hi,
>
>
> I just noticed that in a diskless-system initramfs, mount.nfs4 appears
> to hang whenever it cannot get a response (any response) from the
> rpcbind port. If there is no rpcbind running and thus, TCP RST is sent,
> fine. But if it's dropped, like when the "lo" device is not in the "up"
> state (as can easily happen at this stage of boot), mount.nfs4 waits
> forever.

The rpcbind registration RPC request is "hard".  Maybe it should be "soft".

But a better question is why are you doing an NFS mount if "lo" is not 
up?  NFS has never worked in this case, because there would be no way 
for the kernel to communicate with user space.

-- 
chuck[dot]lever[at]oracle[dot]com
