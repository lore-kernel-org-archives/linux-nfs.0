From: Ingo Molnar <mingo@elte.hu>
Subject: Re: BUG: soft lockup detected on CPU#0! (linux-2.6.14)
Date: Tue, 8 Nov 2005 13:27:44 +0100
Message-ID: <20051108122744.GA3045@elte.hu>
References: <20051106193142.GD26862@skl-net.de> <17262.31781.497775.640424@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andre Noll <maan@systemlinux.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZSZa-0002pc-U5
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 04:27:34 -0800
Received: from mx3.mail.elte.hu ([157.181.1.138])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZSZZ-00050N-JZ
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 04:27:34 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17262.31781.497775.640424@cse.unsw.edu.au>
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


* Neil Brown <neilb@suse.de> wrote:

> > Nov  4 12:46:44 p133 kernel: BUG: soft lockup detected on CPU#0!
> 
> This seems to suggest that the nfsd thread is always runnable, which 
> implies a read-only load with everything in cache - at least for the 
> 10 seconds leading up to each of these errors.  Is that likely?
> 
> The following patch might fix it.  Please let me know the result.

>  	try_to_freeze();
> +	cond_resched();

and the NFSd thread never considered preemption in any other place? Then 
this should be the right fix - the kernel was running under !PREEMPT.

	Ingo


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
