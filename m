From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 01:00:27 -0500
Message-ID: <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com>
References: <20081109164132.GA19615@uio.no>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:23629 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbYKLGAg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 01:00:36 -0500
In-Reply-To: <20081109164132.GA19615-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar-

Thanks for testing!

Keep an eye out for IPv6-related patches for nfs-utils.  The key is to  
ensure IPv4 continues to work, especially on Debian which tracks  
upstream nfs-utils closely.

On Nov 9, 2008, at 11:41 AM, Steinar H. Gunderson wrote:

> Hi,
>
> I'm sure others have gotten this to work at some point, but it's  
> finally
> gotten to the point where I could get it to work myself, so I  
> thought I could
> share my success story:
>
> - Vanilla 2.6.28-rc3 client (2.6.26 also worked, although not with  
> NFSv4)
> - Solaris 10 server
> - libtirpc from git (git://git.infradead.org/~steved/libtirpc.git)
> - IPv6-patched nfs-utils from git
>   (git://git.linux-nfs.org/projects/cel/nfs-utils.git)
>
> After recompiling (actually making Debian packages of) the client  
> software,
> it was just a matter of mounting. 2.6.26 had some issues with IPv6  
> address
> literals -- only DNS worked -- but 2.6.28-rc3 did both just fine.
>
> I haven't done extensive testing, but this looks pretty good :-) Now  
> I'm just
> waiting for the server support to get ready in the same way, and  
> then for
> everything to trickle into mainline.
>
> /* Steinar */
> -- 
> Homepage: http://www.sesse.net/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



