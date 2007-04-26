From: Fabio Olive Leite <fleite@redhat.com>
Subject: time_after cannot be used alone by NFS code in 32bit
	architectures
Date: Thu, 26 Apr 2007 01:33:44 -0300
Message-ID: <20070426043344.GO10449@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GID0FwUMdk1T2AWN"
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgvfs-00086x-G6
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:33:44 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hgvfu-000207-Kx
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 21:33:47 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q4Xjfi024953
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 00:33:45 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q4XjP8012197
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 00:33:45 -0400
Received: from sleipnir.redhat.com (vpn-14-22.rdu.redhat.com [10.11.14.22])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3Q4XgAO006295
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 00:33:43 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l3Q4Xjv3005676
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 01:33:46 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l3Q4XifY005675
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 01:33:44 -0300
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


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi nfs@,

This is going to be tough, so bear with me for a while. :)

While I was trying to understand the effects of wrapping jiffies in
the various timestamp comparisons the NFS code does among its data
structures, I was struck by cases where the code flow just did not
make sense (checking with nfs_debug set to 32767 and additional
systemtap scripts to extract debug info), considering the jiffy
timestamps involved. This is the investigation that ensued.

time_after and friends provide a very clever way to compare two jiffy
counts when those two counts are close together, and indeed does
provide sign flip resistance, when the two values are close together.
So it is ideal for short-lived timers and timeouts, since one would be
usually comparing values a few thousands or even millions apart.

But unfortunately for the NFS code, time_after and friends alone are
not well suited if we're just comparing jiffy counts taken at random
times in the past instead of at moments close together. Exactly the
protection against sign flips backfires when comparing timestamps over
2 billion counts apart.

The NFS data structures can easily be left idle for over 2 billion
jiffies, which is about 25 days with an HZ of 1000. So consider a
file's nfs_fattr data has a timestamp of 0x3fffffff. About 25 days
later this file is accessed again, and the new attributes from the
server get tagged with a timestamp of 0xc0000000. Those new attributes
are clearly newer than what we had before, yet
time_after(0xc0000000,0x3fffffff) returns 0, and the older attributes
remain in use. Yes, those values are corner cases, but they are
actually just the limits of a range of values with similar behavior.

The ascii chart below shows that the sign flip protection of
time_after extends to a lot more than what we'd like for the NFS
timestamp comparisons.

t      b  0 0 0 3 4 7 7 7 8 8 8 b c f f f
 i        0 0 0 f 0 f f f 0 0 0 f 0 f f f
  m       0 0 0 f 0 f f f 0 0 0 f 0 f f f
   e      0 0 0 f 0 f f f 0 0 0 f 0 f f f
    _     0 0 0 f 0 f f f 0 0 0 f 0 f f f
     a    0 0 0 f 0 f f f 0 0 0 f 0 f f f
      f   0 0 0 f 0 f f f 0 0 0 f 0 f f f
a      t  0 1 2 f 0 d e f 0 1 2 f 0 d e f

00000000  0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1=20
00000001  1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1=20
00000002  1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1=20
3fffffff  1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1=20
40000000  1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1=20
7ffffffd  1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1=20
7ffffffe  1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1=20
7fffffff  1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1=20
80000000  1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0=20
80000001  0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0=20
80000002  0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0=20
bfffffff  0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0=20
c0000000  0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0=20
fffffffd  0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0=20
fffffffe  0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0=20
ffffffff  0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0=20

This leads to several problematic situations in long-lived NFS mounts.
We can see old attributes not being updated, negative dentries that do
not revalidate even after touching their parent dir, etc.

So something more robust is needed when comparing two timestamps in
NFS data structures, or we should convert the code to use 64bit
jiffies everywhere, even on 32bit architectures. This probably affects
many other things in the rest of the kernel, but I don't think many
other data structures are as long-lived as the NFS ones.

Attached are two small programs to help understand the issue, one that
generates the matrix above, the other being a simple time_after
calculator for checking specific values. Compile and run on 32bit
boxes, of course.

Although this sounds like the perfect push for using autofs, I'm sure
long-lived (over 100 days, allowing for two rounds of u32 jiffies and
timestamps all over the place) NFS mounts on 32bit architectures will
still be very common for a long time. :)

Comments? I'd love to be proved wrong, as right now I'm very scared.

Regards,
F=E1bio
--=20
ex sed lex awk yacc, e pluribus unix, amem

--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time_after_matrix.c"

#include <stdio.h>

#define typecheck(type,x) \
({      type __dummy; \
        typeof(x) __dummy2; \
        (void)(&__dummy == &__dummy2); \
        1; \
})

#define time_after(a,b)         \
        (typecheck(unsigned long, a) && \
         typecheck(unsigned long, b) && \
         ((long)(b) - (long)(a) < 0))
#define time_before(a,b)        time_after(b,a)

#define time_after_eq(a,b)      \
        (typecheck(unsigned long, a) && \
         typecheck(unsigned long, b) && \
         ((long)(a) - (long)(b) >= 0))
#define time_before_eq(a,b)     time_after_eq(b,a)

int main() {
	unsigned long i, j;
	unsigned long values[] = {
		0x00000000,
		0x00000001,
		0x00000002,
		0x3fffffff,
		0x40000000,
		0x7ffffffd,
		0x7ffffffe,
		0x7fffffff,
		0x80000000,
		0x80000001,
		0x80000002,
		0xbfffffff,
		0xc0000000,
		0xfffffffd,
		0xfffffffe,
		0xffffffff
	};

	/* Lame! =) */
	printf("t      b  0 0 0 3 4 7 7 7 8 8 8 b c f f f\n");
	printf(" i        0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("  m       0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("   e      0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("    _     0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("     a    0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("      f   0 0 0 f 0 f f f 0 0 0 f 0 f f f\n");
	printf("a      t  0 1 2 f 0 d e f 0 1 2 f 0 d e f\n");
	printf("\n");

	for (i = 0; i < 16; i++) {
		printf("%08lx  ", values[i]);
		for (j = 0; j < 16; j++) {
			printf("%d ", time_after(values[i],values[j]));
		}
		printf("\n");
	}

	return 0;
}

--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time_after_calc.c"

#include <stdio.h>

#define typecheck(type,x) \
({      type __dummy; \
        typeof(x) __dummy2; \
        (void)(&__dummy == &__dummy2); \
        1; \
})

#define time_after(a,b)         \
        (typecheck(unsigned long, a) && \
         typecheck(unsigned long, b) && \
         ((long)(b) - (long)(a) < 0))
#define time_before(a,b)        time_after(b,a)

#define time_after_eq(a,b)      \
        (typecheck(unsigned long, a) && \
         typecheck(unsigned long, b) && \
         ((long)(a) - (long)(b) >= 0))
#define time_before_eq(a,b)     time_after_eq(b,a)

int main() {
	unsigned long a, b;

	printf("Type in series of two space-separated hex values, ^D to end.\n");

	while (scanf("%lx %lx", &a, &b) == 2)
		printf("time_after(%lx,%lx) == %d\n", a, b, time_after(a,b));

	return 0;
}

--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--GID0FwUMdk1T2AWN--
