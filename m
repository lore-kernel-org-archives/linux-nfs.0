From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: /var/lib/nfs/v4recovery
Date: Fri, 10 Mar 2006 10:26:03 -0500
Message-ID: <20060310152603.GD24554@fieldses.org>
References: <20060310071803.8229.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHjVI-00037D-Nn
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 07:26:08 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHjVF-00045U-RE
	for nfs@lists.sourceforge.net; Fri, 10 Mar 2006 07:26:08 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060310071803.8229.qmail@web51601.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Mar 09, 2006 at 11:18:03PM -0800, mehta kiran wrote:
>    I could see that it is mentioned that
>    /var/lib/nfs/v4recovery needs to be created
>    for NFSv4 at 
>  
> http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html.

We've had some negative feedback on the way we're storing persistant
state for reboot recovery.  Among other problems:
	- There's an objection (which I don't entirely claim to
	  understand) against nfsd doing directory operations in the
	  kernel
	- It doesn't give any chance for synchronous callouts for, e.g.,
	  mirroring the data to a backup server for failover, whereas
	  the standard statd stuff does.

Hopefully this will fixed by 2.6.17 or 2.6.18.

>    1. What is this file for ?
>       As NFSv4 uses lease based locking , it does
>       create files on persistent storage.
>       And its state could be stored   
>       in /var/lib/nfs/statd/state , right ?

I don't think we can store the state in exactly the same place, but we
probably will move to something more similar to statd.

>    2. I have read that lease time for NFSV4 can be 
>       chnaged by setting value in
>       /proc/fs/nfsd/nfsv4leasetime. In case i dont
>       set lease period  , is grace period set by user
>       considered as the lease time ?

Since we use leases to implement delegations, there's an ugly conflict
between /proc/sys/fs/lease-break-time and /proc/fs/nfsd/nfsv4leasetime,
which we're currently working on fixing.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
