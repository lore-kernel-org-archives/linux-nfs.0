From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: NFSERR_EAGAIN - resolved.
Date: Wed, 16 Jul 2003 16:53:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F15750B.9080302@cinesite.co.uk>
References: <3F0DB088.303@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Iain Irwin-Powell <Iain@cinesite.co.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cobm-0001Xh-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 08:54:22 -0700
Received: from sirius.cinesite.co.uk (sirius.cinesite.co.uk [10.66.0.23])
	by scanman.cinesite.co.uk (8.9.3/8.9.3) with ESMTP id QAA21674
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 16:53:48 +0100 (BST)
To: nfs <nfs@lists.sourceforge.net>
In-Reply-To: <3F0DB088.303@cinesite.co.uk>
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

Danny Smith wrote:

> I've been trying to resolve some issues we have with a set of systems 
> running 2.4.20+NFS_ALL, dual CPU and Gigabit Ethernet. They're talking 
> to SGI IRIX servers, (6.5.19), and having intermittent problems - this 
> can be seen sometimes where an NFS mounted directory will "disappear", 
> but subsequently be accessible. No errors are returned to the shell - 
> the directory just appears to have no entries.
>
> This seems (although I don't have proof positive yet, more testing is 
> in progrees) to coincide with errors in the logs:
>
> Jul  9 14:18:09 trout-node13 kernel: nfs_stat_to_errno: bad nfs status 
> return value: 11
>
I've found the cause of these messages - SGI are in the clear - it's not 
coming from their servers.
It's 'amd' (am-utils) which is providing the incorrect responses.

Trigger seems to be trying to access an automount on a host which is not 
running an NFS server. amd then sends back a garbled response over the 
loopback interface (after getting several "RPC - program not registered" 
responses).

Whether this is causing our other problems remains to be seen.

Danny

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
