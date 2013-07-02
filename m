Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4.gandi.net ([217.70.183.210]:52385 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550Ab3GBRIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 13:08:53 -0400
Date: Tue, 2 Jul 2013 19:02:16 +0200
From: William Dauchy <william@gandi.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: pascal@gandi.net, linux-nfs@vger.kernel.org
Subject: Strange NFS/async write issue
Message-ID: <20130702170216.GH30876@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WR+jf/RUebEcofwt"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--WR+jf/RUebEcofwt
Content-Type: multipart/mixed; boundary="r5lq+205vWdkqwtk"
Content-Disposition: inline


--r5lq+205vWdkqwtk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Trond,

We wrote the attached tester to reproduce an issue we have with mysql on
a 3.9.8 kernel using a nfsv4 mount.=20

mount options are "classic":

rw,nosuid,nodev,noexec,relatime,vers=3D4.0,rsize=3D1048576,wsize=3D1048576,=
namlen=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,local_lock=
=3Dnone

When handling a temporary file, mysql open(), then writes a bunch (say ~16M=
B) of data
to that file, lseeks to the start and re-reads file contents.

With the code as attached, we see a lot of small NFS writes (1400 bytes) and
a lot of getattrs [1] and the test takes a little more than 2 seconds.

It seems the lseek/read are serialized to the last write actually sent to t=
he filer -=20
and nothing aggregates the big writes.

If we uncomment the fsync() call, or simply close() and reopen the file, th=
e test
completes in a few milliseconds. Same if we call sync() from any process wh=
ile this
test is running. Dump shows lots of big tcp pushes, few NFS commands/answer=
s - no
getattr in between writes.

Is this an issue worth a dig or a known behaviour?
Can we debug this a bit further for you?

Thanks for your time,

[1]
(extract from the dump:
15:56:43.681766 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 143999=
80:14401384, ack 1038253, win 24576, options [nop,nop,TS val 928349822 ecr =
259987202], length 1404
15:56:43.685189 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 1439998=
0, win 32715, options [nop,nop,TS val 259987203 ecr 928349822], length 0
15:56:43.689131 IP 10.0.41.39.2049 > 10.0.46.65.263281194: reply ok 132 get=
attr NON 3 ids 0/38 sz 0
15:56:43.689292 IP 10.0.46.65.280058410 > 10.0.41.39.2049: 2892 getattr fh =
0,0/22
15:56:43.689330 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 144042=
80:14405684, ack 1038389, win 24576, options [nop,nop,TS val 928349824 ecr =
259987203], length 1404
15:56:43.690127 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 1440428=
0, win 32715, options [nop,nop,TS val 259987203 ecr 928349824], length 0
15:56:43.690651 IP 10.0.41.39.2049 > 10.0.46.65.280058410: reply ok 132 get=
attr NON 3 ids 0/38 sz 0
15:56:43.690769 IP 10.0.46.65.296835626 > 10.0.41.39.2049: 2892 getattr fh =
0,0/22
15:56:43.690782 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 144085=
80:14409984, ack 1038525, win 24576, options [nop,nop,TS val 928349824 ecr =
259987203], length 1404
15:56:43.691496 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 1440858=
0, win 32715, options [nop,nop,TS val 259987203 ecr 928349824], length 0
15:56:43.692970 IP 10.0.41.39.2049 > 10.0.46.65.296835626: reply ok 132 get=
attr NON 3 ids 0/38 sz 0
15:56:43.693194 IP 10.0.46.65.313612842 > 10.0.41.39.2049: 2892 getattr fh =
0,0/22
15:56:43.693249 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 144128=
80:14414284, ack 1038661, win 24576, options [nop,nop,TS val 928349825 ecr =
259987204], length 1404
15:56:43.693395 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 1441288=
0, win 32715, options [nop,nop,TS val 259987204 ecr 928349825], length 0
15:56:43.693644 IP 10.0.41.39.2049 > 10.0.46.65.313612842: reply ok 132 get=
attr NON 3 ids 0/38 sz 0
)

--=20
William

--r5lq+205vWdkqwtk
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="nfssync.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
    int i, fd;
    time_t ts;
    char *fakebuf;

    if (argc < 2)
        exit(1);

    fd = open(argv[1], O_RDWR|O_CREAT|O_EXCL|O_TRUNC|O_NOFOLLOW, 0755);
    if (fd < 0) {
        perror("open");
        exit(1);
    }

    fakebuf = malloc(256*1024);
    if (fakebuf == NULL) {
        perror("malloc");
        exit(1);
    }

    ts = time(NULL);
    printf("writing..");
    memset(fakebuf, 'A', 256*1024);
    for (i = 0; i < 68; i++)
        write(fd, fakebuf, 256*1024);
    printf("done in %lu secs\n", time(NULL) - ts);

    ts = time(NULL);
    printf("not syncing..");
    // fsync(fd);
    printf("synced in %lu secs\n", time(NULL) - ts);

    printf("reading..");

    ts = time(NULL);
    if (fd < 0) {
        perror("open");
        exit(1);
    }

    // just mimic mysql stuff
    lseek(fd, 0, SEEK_CUR);
    lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);
    for (i = 0; i < 68; i++)
        read(fd, fakebuf, 256*1024);
    printf("done in %lu secs\n", time(NULL) - ts);

    return 0;
}

--r5lq+205vWdkqwtk--

--WR+jf/RUebEcofwt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlHTB5gACgkQ1I6eqOUidQGkcgCeOm3FgsPL+I7Nm6we5N/7XSkT
VKIAnA487VlkZ/g3TfcoasL3a3EQWC5k
=GjKF
-----END PGP SIGNATURE-----

--WR+jf/RUebEcofwt--
