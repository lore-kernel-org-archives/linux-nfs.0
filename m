Return-Path: linux-nfs-owner@vger.kernel.org
Received: from audible.transient.net ([216.254.12.79]:52599 "HELO
	audible.transient.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751197Ab2HOGR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 02:17:58 -0400
Date: Wed, 15 Aug 2012 06:11:15 +0000
From: Jamie Heilman <jamie@audible.transient.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to return
Message-ID: <20120815061115.GC32347@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I really wish I could have nailed this down better, but I've had a
hard time reliably reproducing the problem during bisection, and I
haven't seen anyone report a similar sounding problem.  Here's what
I've seen: since 3.5 I've been having spurious delays on my nfs
clients, noticable particularly when I open an mbox file in mutt over
an nfs v4 mount from a v3.5 or later server.  The servers I've
reproduced this on are all uni-proc 32-bit systems... but then I
haven't tried SMP or 64-bit systems yet, it may or may not exist
there.  When the delay occurs, it's quite noticable.  I've never seen
one that takes less than 40 seconds to "unstick."  I wrote a quick and
dirty reproduction tool, based on the syscalls mutt was doing that
triggered the problem, attached to this message.  To use it, compile
the file as utime-test on an exported volume, then execute with (cd
/some/mount/point && strace -T ./utime-test) from a nfs4 client.

For whatever, reason I frequently find the second call to utime takes
an irritatingly long time to return and I see something like:
utime("utime-test.c", [2012/08/14-22:47:21, 2012/08/14-17:25:21]) = 0 <70.510913>
in the strace output.

I've reproduced this on Debian Squeeze / nfs-utils 1.2.2 based servers
(legacy idmapper, no user-space nfsidmap), as well as Debian Wheezy /
nfs-utils 1.2.6 (uses keyutils upcalls) servers, so I doubt it's a
user-space related issue...  Attempts to bisect have been muddled,
I'll keep trying in the interim, but the best I've been able to pin
things down is that issue was probably introduced in the
419f4319495043a9507ac3e616be9ca60af09744 merge.  I can't repo on a
kernel based on fb21affa49204acd409328415b49bfe90136653c.  (I say
based on, because I have to apply the patch from
http://marc.info/?l=linux-nfs&m=133950479803025 or face additional
problems.)

I'll try to get full rcpdebug traces on client and server as the delay
is occuring in the hopes that helps pin things down, and post them
separately.

-- 
Jamie Heilman                     http://audible.transient.net/~jamie/

--sdtB3X0nJg68CQEu
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="utime-test.c"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <utime.h>
#include <stdio.h>

#define F_PATH "utime-test.c"

int main()
{
	struct stat sb;
	struct utimbuf ub;
	int fd;

	if (stat(F_PATH, &sb) == -1) {
		perror(NULL);
		return -1;
	}
	ub.modtime = sb.st_mtime;
	ub.actime = time(NULL);
	if (utime(F_PATH, &ub) == -1) {
		perror(NULL);
		return -2;
	}
	if ((fd = open(F_PATH, O_RDONLY)) == -1) {
		perror(NULL);
		return -3;
	}
	close(fd);
	if (stat(F_PATH, &sb) == -1) {
		perror(NULL);
		return -1;
	}
	ub.modtime = sb.st_mtime;
	ub.actime = time(NULL);
	if (utime(F_PATH, &ub) == -1) {
		perror(NULL);
		return -2;
	}

	return 0;
}

--sdtB3X0nJg68CQEu--
