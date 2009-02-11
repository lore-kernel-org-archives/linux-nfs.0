From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Wed, 11 Feb 2009 21:37:03 +0100
Message-ID: <20090211203703.GA9662@janus>
References: <20090211112318.GA29133@janus> <20090211203555.GC27686@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:43815 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752831AbZBKUhF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2009 15:37:05 -0500
In-Reply-To: <20090211203555.GC27686@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2009 at 03:35:55PM -0500, J. Bruce Fields wrote:
> On Wed, Feb 11, 2009 at 12:23:18PM +0100, Frank van Maarseveen wrote:
> > I'm sorry to inform you but... it seems that there is a similar problem
> > in the NLM subsystem as reported previously but this time it is triggered
> > when the grace time expires after a reboot.
> > 
> > Client and server run 2.6.27.14 + previous fix, NFSv3.
> > 
> > On the client there are three shells running:
> > 
> > 	while :; do lck -w /mnt/foo 2; done
> > 
> > The "lck" program is the same as posted before and it obtains an exclusive
> > write lock then waits 2 seconds in above invocation (there's probably an
> > "fcntl" command equivalent). After an orderly server reboot + grace time
> 
> How are you rebooting the server?

"reboot"

> 
> --b.
> 
> > expiration one of above command loops reports:
> > 
> > 	lck: fcntl: No locks available
> > 
> > and all three get stuck. After ^C-ing all "lck" loops the server still
> > shows an entry in /proc/locks which causes the file to be locked
> > indefinately. Maybe two loops are sufficient to reproduce the issue or
> > maybe you need more, I don't know.
> > 
> > Interestingly, during the grace time at least one of the "lck" processes
> > should have re-obtained the lock but it didn't show up in /proc/locks
> > on the server.
> > 
> > Interestingly (#2), after removing the file on the server (i.e. no
> > sillyrename) the now free inode is still locked according to /proc/locks.
> > Even stopping/starting /etc/init.d/nfs-kernel-server plus "echo
> > 3 >/proc/sys/vm/drop_caches" did not remove the lock (it did re-enter
> > grace).
> > 
> > -- 
> > Frank
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Frank
