From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: mount retries
Date: Fri, 02 Oct 2009 21:35:21 -0500
Message-ID: <4AC6B869.60002@excfb.com>
References: <4AC67481.20900@excfb.com> <FED38E90-C32D-43E8-A0A2-5A37E4BB894F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:51885 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbZJCCgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2009 22:36:08 -0400
In-Reply-To: <FED38E90-C32D-43E8-A0A2-5A37E4BB894F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>
> The exact retry behavior depends on whether user space or the kernel 
> is trying to do the talking.  NFSv4 and text-based NFSv2/v3 mounts do 
> most of the talking from the kernel.  Text-based mounts do a user 
> space pmap query or two, but the MNT request comes from the kernel.  
> Also, UDP retries a few times, but usually gives up after 30 seconds 
> or so, but TCP can retry the transport connect for over 3 minutes, 
> even before it gets to send any requests at all.
>
> I'm pretty sure I didn't answer your question.

Thanks Chuck, you actually nailed what I didn't ask properly.

The UDP retries being at 30s correlates with what I was seeing.
