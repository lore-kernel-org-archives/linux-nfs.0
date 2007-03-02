From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: NFS client locks sometimes not removed from server
	(reproducable)
Date: Fri, 2 Mar 2007 16:51:45 +0100
Message-ID: <20070302155145.GA12177@janus>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNA2w-0005Go-Gd
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 07:51:50 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HNA2x-0003MS-38
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 07:51:52 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Client and server are the same. Kernels tried: 2.6.19, 2.6.20 and
2.6.20.1 + http://client.linux-nfs.org/Linux-2.6.x/2.6.20/linux-2.6.20-NFS_ALL.dif

kernel compiled with gcc version 3.4.6 (Debian 3.4.6-4)

/proc/mounts says:

server:/mnt /net/server/mnt nfs rw,nosuid,nodev,vers=3,rsize=32768,wsize=32768,hard,proto=udp,timeo=11,retrans=2,sec=sys,addr=server 0 0


cd /net/server/mnt
mkdir t
cd t
 (save lck.c and locktest attachments here)
gcc -o lck lck.c
./locktest


When the script terminates:
-	ls -li lck-filename
		(remember the inode #)
-	ps wwwuax|grep lck
		(there should not be any running)
-	cat /proc/locks
		(inode appears not locked)
-	ssh server cat /proc/locks
		(inode appears locked!)

Trying the same against a tru64 server shows similar symptoms (the file
can no longer be locked. tru64 has no /proc/locks of course).

A possibly related issue: when the client is shut down it says

	lockd_down: lockd failed to exit, clearing pid

when the client reboots (rpc.statd?) the server seems to remove the
corresponding locks which is a smart thing to do.

-- 
Frank

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lck.c"

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
void die(const char *fmt, ...)
{
	va_list	ap;

	va_start(ap, fmt);
	fprintf(stderr, "lck: ");
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	exit(1);
}

int main(int argc, char **argv)
{
	struct flock flock = {0};
	int i, d, locktime, cmd;
	const char *name;

	flock.l_type = F_WRLCK;		/* -w */
	flock.l_whence = SEEK_SET;
	cmd = F_SETLKW;			/* no -t */
	name = NULL;
	locktime = 10;
	for (i = 1; i < argc; ++i) {
		if (strcmp(argv[i], "-r") == 0)
			flock.l_type = F_RDLCK;		/* lock for N readers */
		else if (strcmp(argv[i], "-w") == 0)
			flock.l_type = F_WRLCK;		/* lock for 1 writer */
		else if (strcmp(argv[i], "-t") == 0)
			cmd = F_SETLK;			/* test for a lock, don't wait */
		else if (argv[i][0] == '-')
			die("Usage: lck [-r|-w] [-t] [<filename> [<locktime>]]\n");
		else if (name && isdigit(argv[i][0]))
			locktime = atoi(argv[i]);	/* after acquiring lock, wait locktime seconds */
		else
			name = argv[i];
	}
	if (!name)
		name = "lck-filename";
	d = open(name, O_RDWR|O_CREAT, 0666);
	if (d == -1)
		die("open %s: %s\n", name, strerror(errno));
	if (fcntl(d, cmd, &flock) == -1)
		die("fcntl: %s\n", strerror(errno));
	printf("locked...");
	fflush(NULL);
	sleep(locktime);
	if (close(d))
		die("close: %s\n", strerror(errno));
	printf("unlocked.\n");
	return 0;
}

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=locktest

#!/bin/sh

trap ' exit ' 1 2 3 15
trap ' fuser -k $lck ; rm -f $lck ' 0

lck=`mktemp -t lckXXXXXX`
cp lck $lck
chmod +x $lck

rm -f lck-filename

function f1()
{
	while :
	do
		$lck lck-filename 1
		sleep 1
	done
}

function f2()
{
	while :
	do
		$lck lck-filename 0
	done
}

function f3()
{
	while :
	do
		$lck -r lck-filename 0
	done
}

function f4()
{
	while :
	do
		$lck -r -t lck-filename 0
	done
}

while :
do
	( f1 & f2 & f3 & f4 ) 9<$lck  &
	sleep 5
	fuser -k $lck
	sleep 2
	echo -n write lock test:
	lck -t lck-filename 0 || exit
done

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--vtzGhvizbBRQ85DL--
