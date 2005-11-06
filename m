From: Andre Noll <maan@systemlinux.org>
Subject: Re: BUG: soft lockup detected on CPU#0! (linux-2.6.14)
Date: Sun, 6 Nov 2005 23:51:38 +0100
Message-ID: <20051106225138.GF26862@skl-net.de>
References: <20051106193142.GD26862@skl-net.de> <17262.31781.497775.640424@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EYtMW-0004gs-O1
	for nfs@lists.sourceforge.net; Sun, 06 Nov 2005 14:51:44 -0800
Received: from systemlinux.org ([83.151.29.59] helo=m18s25.vlinux.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EYtMV-00027K-JW
	for nfs@lists.sourceforge.net; Sun, 06 Nov 2005 14:51:44 -0800
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

On 08:56, Neil Brown wrote:
> This seems to suggest that the nfsd thread is always runnable, which
> implies a read-only load with everything in cache - at least for the
> 10 seconds leading up to each of these errors.  Is that likely?

Hm, not sure. I was compiling glibc and simultanously running a big
"cvs update" on the nfs server when one of these BUGs happened.

glibc source and the cvs tree live somewhere in /home and /home is
exported rw to a bunch of clients. But no client should have accessed
those two subdirs at that time.

> The following patch might fix it.  Please let me know the result.

Patch applied and rebooted. The box currently compiles glibc and
firefox in parallel. No problems so far.

Thanks a lot
Andre
-- 
Jesus not only saves, he also frequently makes backups


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
