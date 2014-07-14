Return-Path: linux-nfs-owner@vger.kernel.org
Received: from whm03.asteroidpc.com ([204.191.218.7]:39518 "EHLO
	whm03.asteroidpc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501AbaGNR3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 13:29:49 -0400
Message-ID: <53C4138B.2060504@nathanshearer.ca>
Date: Mon, 14 Jul 2014 11:29:47 -0600
From: Nathan Shearer <mail@nathanshearer.ca>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: umount -f stalls forever
References: <53BDA2C7.4030007@nathanshearer.ca> <20140710151112.7710bb7b@notabene.brown>
In-Reply-To: <20140710151112.7710bb7b@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/07/2014 11:11 PM, NeilBrown wrote:
> Hi Nathan, you don't say what kernel you are running.... A change was 
> made in Linux 3.12 (8033426e6bdb2690d302872ac1e1fadaec1a5581) which 
> may address the problem you have. So if you are using a kernel older 
> than that, try a newer kernel. This may not make "umount -f" work, but 
> it should stop it from hanging. To make it work you might need to kill 
> all the processes using the mount point first. Also, "umount -l" might 
> be a suitable answer to your problems. NeilBrown 

Hi Neil,

Thanks for the quick reply. The fileserver I ran into this issue on is 
running a relatively old kernel:

Linux version 3.0.0-12-server (buildd@crested) (gcc version 4.6.1 
(Ubuntu/Linaro 4.6.1-9ubuntu3) ) #20-Ubuntu SMP Fri Oct 7 16:36:30 UTC 2011

I haven't tried umount -f on a recent kernel with a stalled hard mounted 
nfs share yet, but it's great to know that the issue is resolved :)
I was mostly reporting the issue in case it wasn't resolved, and also 
creating some documentation in the mailing list in case anybody needed 
to unmount a stalled nfs share in the future and needed a way to do it.
