From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: How to enable debugging on NFS (dprintk)?
Date: Thu, 17 Jul 2003 15:33:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F16B3C0.4050103@cinesite.co.uk>
References: <20030717110725.GA24400@pelvoux.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19d9pl-0004xk-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 07:34:13 -0700
To: Steve Fosdick <lists@pelvoux.nildram.co.uk>
In-Reply-To: <20030717110725.GA24400@pelvoux.gotadsl.co.uk>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

It's controlled by /proc/sys/sunrpc/nfs_debug (or nfsd_debug for the 
server).

Not totally sure of the valid values, but it's an int bit field, so this 
will turn most things on (client side):

echo 65535 > /proc/sys/sunrpc/nfs_debug

Danny



Steve Fosdick wrote:

> There are some calls to dprintk within the NFS kernel code - how to I 
> set things up to I can see the messages from these calls please?
>
> Steve.
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: VM Ware
> With VMware you can run multiple operating systems on a single machine.
> WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
> same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
