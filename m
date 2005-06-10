From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS crash on Suse, any ideas on which normal nfs patch could be a cause/fix?
Date: Fri, 10 Jun 2005 09:56:37 +0200
Message-ID: <20050610075637.GB5534@suse.de>
References: <EXCHG2003FbN4TZyabY000003d9@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DgeNf-0004YO-4R
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 00:56:43 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DgeNe-0000MG-2x
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 00:56:42 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003FbN4TZyabY000003d9@EXCHG2003.microtech-ks.com>
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

On Thu, Jun 09, 2005 at 01:50:13PM -0500, Roger Heflin wrote:
> The kernel crash message was:
> 
> CPU 0: Machine Check Exception:          4 Bank 4: f60da00100000813
>   RIP !INEXACT!  10:<ffffffff8022fae2> {copy_user_generic_c0x8/0x26}
>   TSC 3d101af6bf756 ADDR 4304010
>   Kernel panic: Machine check

This is not an NFS bug, it's a machine check exception. Your machines
have bad RAM it seems.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
