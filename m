From: Thomas Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: To Automount or to Not Automount?
Date: Thu, 14 Jan 2010 14:58:29 -0600
Message-ID: <4B4F8575.1010505@sun.com>
References: <hint4t$gjt$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:49691 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab0ANVNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 16:13:22 -0500
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id o0EKwZjp001005
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jan 2010 20:58:36 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KW900K0085BCL00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Thu,
 14 Jan 2010 13:58:35 -0700 (MST)
In-reply-to: <hint4t$gjt$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jon Forrest wrote:
>
> So, I'd like to ask the NFS experts on this
> list whether in a CentOS 5 environment with
> NFS3 mounts over a functional private network,
> would using static mounts result in any negatives
> as compared to automounts. I'm especially interested
> in overhead on the NFS server.
>
> Cordially,

Is every node mounting every other node?

Or are you talking about every node mounting a central
server?

The static mounts would happen on boot and you might
have issues if every node was trying to mount every other
node. With automounts, you would delay the mounting
until the booting node has to access the other node.

I had this issue way back in 1998 with a Beowulf
cluster.  Heating issues forced me to shut down all
of the nodes at the same time and the interdependencies
in the mounts caused the bringup to be slow. :->
