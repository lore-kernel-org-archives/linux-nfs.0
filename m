From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: NFSv3 locking bugs (trace+testprogram included)
Date: Fri, 29 Jun 2007 17:52:26 +0200
Message-ID: <20070629155226.GA25561@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4Ill-0000OE-ID
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 08:52:25 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I4Ilo-0000XU-3P
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 08:52:29 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Both server and client run 2.6.21.5 and use NFSv3 over UDP.

The server has a second IP address on eth0. The client mounts from the
second address. Two instances of attached test program run on the client
specifying the same lockfile. Basically they repeatedly F_SETLKW for
an exclusive lock, sleep 0.2s with lock held, unlock, sleep 0.1s. The
F_SETLKW is aborted by alarm(10) which normally shouldn't happen.

This works for a minute and then both alarm clocks go off and the file is
still locked on the server but not on the client. Wireshark NLM traffic:

No.     Time        Source                Destination           Protocol Info
   2419 60.152717   client                server                NLM      V4 UNLOCK Call (Reply In 2420) FH:0xe3fa1e5a svid:299 pos:0-0
   2420 60.152871   server                client                NLM      V4 UNLOCK Reply (Call In 2419)
   2423 60.253229   client                server                NLM      V4 LOCK Call (Reply In 2424) FH:0xe3fa1e5a svid:301 pos:0-0
   2424 60.253362   server                client                NLM      V4 LOCK Reply (Call In 2423)
   2427 60.453680   client                server                NLM      V4 UNLOCK Call (Reply In 2428) FH:0xe3fa1e5a svid:301 pos:0-0
   2428 60.453845   server                client                NLM      V4 UNLOCK Reply (Call In 2427)
   2433 60.554379   client                server                NLM      V4 LOCK Call (Reply In 2434) FH:0xe3fa1e5a svid:302 pos:0-0
   2434 60.554535   server                client                NLM      V4 LOCK Reply (Call In 2433)
   2437 60.754853   client                server                NLM      V4 UNLOCK Call (Reply In 2438) FH:0xe3fa1e5a svid:302 pos:0-0
   2438 60.755018   server                client                NLM      V4 UNLOCK Reply (Call In 2437)
   2443 60.855553   client                server                NLM      V4 LOCK Call (Reply In 2444) FH:0xe3fa1e5a svid:303 pos:0-0
   2444 60.855708   server                client                NLM      V4 LOCK Reply (Call In 2443)
   2447 61.056029   client                server                NLM      V4 UNLOCK Call (Reply In 2448) FH:0xe3fa1e5a svid:303 pos:0-0
   2448 61.056191   server                client                NLM      V4 UNLOCK Reply (Call In 2447)
   2453 61.156725   client                server                NLM      V4 LOCK Call (Reply In 2454) FH:0xe3fa1e5a svid:304 pos:0-0
   2454 61.156881   server                client                NLM      V4 LOCK Reply (Call In 2453)
   2457 61.357201   client                server                NLM      V4 UNLOCK Call (Reply In 2458) FH:0xe3fa1e5a svid:304 pos:0-0
   2458 61.357364   server                client                NLM      V4 UNLOCK Reply (Call In 2457)
   2463 61.457901   client                server                NLM      V4 LOCK Call (Reply In 2464) FH:0xe3fa1e5a svid:305 pos:0-0
   2464 61.458055   server                client                NLM      V4 LOCK Reply (Call In 2463)
   2467 61.658373   client                server                NLM      V4 UNLOCK Call (Reply In 2468) FH:0xe3fa1e5a svid:305 pos:0-0
   2468 61.658537   server                client                NLM      V4 UNLOCK Reply (Call In 2467)
   2473 61.759072   client                server                NLM      V4 LOCK Call (Reply In 2474) FH:0xe3fa1e5a svid:306 pos:0-0
   2474 61.759228   server                client                NLM      V4 LOCK Reply (Call In 2473)
   2477 61.959549   client                server                NLM      V4 UNLOCK Call (Reply In 2478) FH:0xe3fa1e5a svid:306 pos:0-0
   2478 61.959711   server                client                NLM      V4 UNLOCK Reply (Call In 2477)
   2483 62.060253   client                server                NLM      V4 LOCK Call (Reply In 2484) FH:0xe3fa1e5a svid:307 pos:0-0
   2484 62.060401   server                client                NLM      V4 LOCK Reply (Call In 2483)
   2487 62.260718   client                server                NLM      V4 UNLOCK Call (Reply In 2488) FH:0xe3fa1e5a svid:307 pos:0-0
   2488 62.260884   server                client                NLM      V4 UNLOCK Reply (Call In 2487)
   2493 62.361419   client                server                NLM      V4 LOCK Call (Reply In 2494) FH:0xe3fa1e5a svid:308 pos:0-0
   2494 62.361574   server                client                NLM      V4 LOCK Reply (Call In 2493)
   2497 62.561892   client                server                NLM      V4 UNLOCK Call (Reply In 2498) FH:0xe3fa1e5a svid:308 pos:0-0
   2498 62.562057   server                client                NLM      V4 UNLOCK Reply (Call In 2497)
   2503 62.662591   client                server                NLM      V4 LOCK Call (Reply In 2504) FH:0xe3fa1e5a svid:309 pos:0-0
   2504 62.662748   server                client                NLM      V4 LOCK Reply (Call In 2503)
   2507 62.863068   client                server                NLM      V4 UNLOCK Call (Reply In 2508) FH:0xe3fa1e5a svid:309 pos:0-0
   2508 62.863231   server                client                NLM      V4 UNLOCK Reply (Call In 2507)
   2513 62.963765   client                server                NLM      V4 LOCK Call (Reply In 2514) FH:0xe3fa1e5a svid:310 pos:0-0
   2514 62.963922   server                client                NLM      V4 LOCK Reply (Call In 2513)
*  2515 63.152236   client                server                NLM      V4 LOCK Call (Reply In 2516) FH:0xe3fa1e5a svid:300 pos:0-0
   2516 63.152373   server                client                NLM      V4 LOCK Reply (Call In 2515) NLM_BLOCKED
*  2519 63.164248   client                server                NLM      V4 UNLOCK Call (Reply In 2520) FH:0xe3fa1e5a svid:310 pos:0-0
   2520 63.164404   server                client                NLM      V4 UNLOCK Reply (Call In 2519)
   2523 63.165053   172.17.2.244          client                NLM      V4 NULL Call (Reply In 2524)
   2524 63.165121   client                172.17.2.244          NLM      V4 NULL Reply (Call In 2523)
*  2525 63.165303   172.17.2.244          client                NLM      V4 GRANTED_MSG Call (Reply In 2531) FH:0xe3fa1e5a svid:300 pos:0-0
   2528 63.166308   client                172.17.2.244          NLM      V4 NULL Call (Reply In 2529)
   2529 63.166450   172.17.2.244          client                NLM      V4 NULL Reply (Call In 2528)
   2530 63.166515   client                172.17.2.244          NLM      V4 GRANTED_RES Call (Reply In 2532) NLM_DENIED
   2531 63.166553   client                172.17.2.244          NLM      V4 GRANTED_MSG Reply (Call In 2525)
   2532 63.166650   172.17.2.244          client                NLM      V4 GRANTED_RES Reply (Call In 2530)
*  2537 63.264939   client                server                NLM      V4 LOCK Call (Reply In 2538) FH:0xe3fa1e5a svid:311 pos:0-0
   2538 63.265094   server                client                NLM      V4 LOCK Reply (Call In 2537) NLM_BLOCKED
*  2541 70.052854   client                server                NLM      V4 CANCEL Call (Reply In 2543) FH:0xe3fa1e5a svid:300 pos:0-0
   2543 70.052999   server                client                NLM      V4 CANCEL Reply (Call In 2541)
   2545 70.053255   client                server                NLM      V4 UNLOCK Call (Reply In 2546) FH:0xe3fa1e5a svid:312 pos:0-0
   2546 70.053399   server                client                NLM      V4 UNLOCK Reply (Call In 2545)
*  2547 73.264984   client                server                NLM      V4 CANCEL Call (Reply In 2549) FH:0xe3fa1e5a svid:311 pos:0-0
   2548 73.265136   client                server                NLM      V4 UNLOCK Call (Reply In 2550) FH:0xe3fa1e5a svid:313 pos:0-0
   2549 73.265166   server                client                NLM      V4 CANCEL Reply (Call In 2547)
   2550 73.265264   server                client                NLM      V4 UNLOCK Reply (Call In 2548)

Observations:
2515:	lock request with svid:300 yields NLM_BLOCKED. This is the first
	NLM_BLOCKED in the entire log. Detail: the actual fcntl() must
	have happened 3 seconds earlier, around t=60. Let's say this
	is the 1st test program instance.
2519:	The 2nd test program instance releases the conflicting lock.
2525:	server sends GRANTED_MSG but from the wrong IP address, client
	responds with GRANTED_RES NLM_DENIED.

	=> wrong src IP address means server bug?

2537:	Almost exactly 0.1s after 2519 the 2nd test program instance
	tries to lock again with svid:311. This fails with NLM_BLOCKED too.

	=> Assuming the client didn't take the lock in 2525 this is a
	   server bug too?

2541:	The 1st instance dies by SIGALRM, 10 seconds after where we would
	have expected a lock request on the wire with svid:300.
2547:	Exactie 10 seconds ater 2537: 2nd test program instance dies.

According to /proc/locks the server still has the file locked after all
of this which looks like a bug too.


test program:

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>

void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
static const char *me;

int main(int argc, char **argv)
{
	int d;

	me = argv[0];
	if (argc != 2)
		die("missing lockfile pathname.\n");
	while (1) {
		struct flock flock = {0};

		flock.l_type = F_WRLCK;
		flock.l_whence = SEEK_SET;
		d = open(argv[1], O_RDWR|O_CREAT, 0666);
		if (d == -1)
			die("open %s: %s\n", argv[1], strerror(errno));
		alarm(10);
		if (fcntl(d, F_SETLKW, &flock) == -1)
			die("fcntl: %s\n", strerror(errno));
		alarm(0);
		usleep(200000);
		close(d);
		usleep(100000);
	}
}

void die(const char *fmt, ...)
{
	va_list	ap;

	va_start(ap, fmt);
	fprintf(stderr, "%s: ", me);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	exit(1);
}

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
