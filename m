From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NLM GRANT callback using AUTH_NULL is rejected
Date: Thu, 17 Nov 2005 11:27:45 -0500
Message-ID: <20051117162745.GD2337@fieldses.org>
References: <044B81DE141D7443BCE91E8F44B3C1E2013327B7@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ecmc3-0006vO-SU
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:27:51 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ecmc1-0001cP-RS
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:27:51 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E2013327B7@exsvl02.hq.netapp.com>
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

On Thu, Nov 17, 2005 at 08:20:48AM -0800, Lever, Charles wrote:
> was it the judgement of the community that no IP address checking for
> AUTH_NULL callbacks is better than having at least *some* sanity
> checking?  seems reasonable to me to register the IP address of the file
> server so that not just any joe IP address can grant locks.

My memory of the details is hazy now, but I seem to recall that lockd
does check that somewhere.

> obtw, did you happen to have a test to see if GRANTED callbacks were
> being accepted after your patch is applied?  that will save me the
> trouble of working up a test myself.

All I did was run the following on two different machines, and verify
that one got the lock the instant I ^C'd the other.

--b.

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <err.h>

int main(int argc, char *argv[])
{
	char buf[4096];
	struct flock fl;
	int fd, ret;

	if (argc != 2)
		errx(1, "usage: %s file_to_lock", argv[0]);

	fd = open(argv[1], O_RDWR|O_CREAT, 0666);
	if (fd == -1)
		err(1, "open");
	/* Exclusive lock on whole file: */
	fl.l_type = F_WRLCK;
	fl.l_whence = SEEK_SET;
	fl.l_start = 0;
	fl.l_len = 0;
	ret = fcntl(fd, F_SETLKW, &fl);
	if (ret == -1)
		err(1, "fcntl(fd, F_SETLKWD, fl)");
	printf("got lock; waiting\n");
	select(0, NULL, NULL, NULL, NULL);
	exit(0);
}


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
