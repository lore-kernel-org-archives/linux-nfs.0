From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 3 of 3] Fix race conditions with file lock vs close
Date: Mon, 11 Jul 2005 14:54:19 +0200
Message-ID: <20050711125419.GS27163@suse.de>
References: <20050711103254.GI27163@suse.de> <42D266C5.4010203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drxnl-0000XI-0s
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:54:25 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drxnk-0006Qf-Mk
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:54:25 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42D266C5.4010203@redhat.com>
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

On Mon, Jul 11, 2005 at 08:32:05AM -0400, Peter Staubach wrote:
> A different patch was submitted upstream already to address the fcntl/close
> race.  It was accepted into the '-mm' kernel on June 28'th.  That patch is
> attached.

I see, it seems this customer has been spamming just about everyone
about this problem :)

I just wonder how the following can work - your patch seems to drop
local book-keeping of locks completely, unless I misread it:


> +	if (filp->f_op && filp->f_op->lock != NULL)
>  		error = filp->f_op->lock(filp, cmd, file_lock);
> +	else {
> +		for (;;) {
> +			error = __posix_lock_file(inode, file_lock);
> +			if ((error != -EAGAIN) || (cmd == F_SETLK))
> +				break;
> +			error = wait_event_interruptible(file_lock->fl_wait,
> +					!file_lock->fl_next);
> +			if (!error)
> +				continue;
> +	
> +			locks_delete_block(file_lock);
>  			break;
> +		}
> +	}

This means if the application establishes an NFS lock, this will not
be reflected locally - and as a consequence, when the application just
exits, the lock will never be released.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
