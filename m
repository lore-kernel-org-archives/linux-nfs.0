Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792706823;
	b=ZOX+NYs7YtUHdqZqvQhweyZ4zBA0KjGoeW3YVcMGC0pIZvASUGe9Hfbjc3pf8PeFgCJ8
	 cjIWNxvUzDE33fYzKEI8IpEkCxDcRxx6QGvzww9sDHGwvHHWwT47lGnRJ9pDB8nPTDPZ2
	 q7bddoerqqDtV7fADO1ID8NCRPSQUVKFdNn6m1URKwsIOCB/qQI43SQe4zGjXIHfgze0B
	 QVk8Ya4wJ6h46B6a9YbbPQUIgPQ3DyM/DkV3ctwC/g4GJ4KBarTFOK4vnPN2qpCtVGd0j
	 /OI4vzKOXAIUsv3oGizjkHPDCaAobEBkzwe5tBbBdMZYkmvY/3O5HeIqRC8JzjKl/sg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792706823;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=D6r8gmkfTeRDLdTp7HikFgFagyNG4fFAlSGNi93oieQ=;
	b=LxjLqf/ObJj2xTnYYoWerIlO1Pn06oAVJxB3yg4lUYaWW+i5tTKswjQGk4flGAcOsUHz
	 V3wJUXyxsEy9WkeYhekwHfaedtytNffhE/jt6uWEGEGBqLI8UPpl3O02HI1HHh7Xd1vrY
	 14szH6e9l6Fdl8tnfQcwTNTPMyTERJa2ak+vrMprc5tsSUaRJRE/DyxMDrMeNxJH4WxFY
	 bO/4U6qPVQv/JxJN/DrqojJS1gpK5FrW3T7twTjwvAwVJjT3eBQJ4U0w0sh0FSPXxhMmU
	 cg9DYUdI57JhPrs9gOMWJVl8qhHp87Zrn7fm5RMRn+s1Fl+oVJdfbJ4CLA2C6m5Briw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Ns/ghxAI";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0BC4606A31B;
	Thu, 22 Oct 2026 22:07:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ns/ghxAI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6887A1F01825;
	Thu, 22 Oct 2026 22:07:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792706822;
	bh=D6r8gmkfTeRDLdTp7HikFgFagyNG4fFAlSGNi93oieQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Ns/ghxAIiypDmDS2PVSNTwQFFBf2XjOuRyxEJbfix8yjJ5N+/cy+lhyTcCAnqG95H
	 DKGCM4y+P9/betQB04ZGCJB+g96AaFXWzeOwVpa7uUQ+FCslAYjyUlDq36dfuDg/Ej
	 SptkOIHCw2kkiBW28h556c60hqB4KLhy1nqF2BbVR3asm4c88reSpCw+EnvTcxPXRq
	 ISPnCLgVLax4REynrizQwPdd1H2KbMya6mD0u/Y0rSzfEW5+j+dkI02IerSxRJKFNr
	 x5xmJUHCZt0EwIhtKsGYH82NvdOZWW1V0b11KZHEOC5VRV42VIx995JYuQ5NaPwBqW
	 rp+R+/OAULHsQ==
Date: Thu, 22 Oct 2026 18:07:01 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Mike Snitzer <snitzer@hammerspace.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v7 0/5] mm, iomap, NFSD: stop uncached writes reading
 back shared pages
Message-ID: <atqJBS8MlYfeUU-t@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261020220346.28020-1-snitzer@kernel.org>

On Tue, Oct 20, 2026 at 06:03:41PM -0400, Mike Snitzer wrote:
> Hi,
> 
> Please consider this v7 for the v7.5 development cycle, so that it can
> go upstream in the v7.5 merge window.
> 
> An uncached (RWF_DONTCACHE) buffered write drops each page it writes
> once that page is written back.  A page the write covers only partly is
> shared with the neighbouring write, and once the first of the two has
> been written back the second has to read it back from disk before it
> can write its part.  32 threads writing interleaved records to one file
> on XFS (emulated 4Kn NVMe, 4 KiB pages), before and after 3/5:
> 
>   record  pwritev2() flags          4 KiB device       MiB/s
>   bytes                             reads per write
>                                     before   after     before  after
>   47008   RWF_DONTCACHE             0.97     0.000     831     2281
>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.000     601     1227
>   6000    RWF_DONTCACHE             0.97     0.000     121      488
>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.000      90      206

For anyone who wants to reproduce the table, the two inlined files
(below) are what produced the data, with no NFS involved:

  dcwrite.c  N threads writing interleaved records to one file, thread
             r's record s at offset (s*N + r)*RECSZ, one pwritev2() per
             record with the given RWF_ flags.  Each record shares its
             first and last page with the records of two other threads.

  dc-ab.sh   for each record size and flag set: a fresh XFS on an
             emulated 4Kn NVMe namespace, dcwrite, then the device's
             4 KiB reads per write (from /sys/block/<dev>/stat around
             the write and a final sync), the file's resident pages
             after the sync (fincore), and the write rate.

The device is the in-kernel NVMe target's file backend on a tmpfs
image, attached over nvme-loop, so it has NVMe's queue limits and a
4096-byte logical block on a 4 KiB-page kernel, and every read the
page cache sends it is counted.  It needs root, CONFIG_NVME_TARGET and
CONFIG_NVME_TARGET_LOOP, nvme-cli, xfsprogs, util-linux's fincore, and
4 GiB free in /dev/shm:

  cc -O2 -pthread -o dcwrite dcwrite.c
  ./dc-ab.sh /tmp/dc-ab ./dcwrite

On kernel with this v7 patchset's patches 1-4:

rs     flags            | writes    4K-reads   reads/write READ-MiB  | resident-pages  | MiB/s
49152  none             | 21824     15         0.0007      0.1       | 261888/261888   | 318.6
49152  dontcache        | 21824     15         0.0007      0.1       | 0/261888        | 4433.3
49152  dsync            | 21824     15         0.0007      0.1       | 261888/261888   | 1074.9
49152  dontcache,dsync  | 21824     15         0.0007      0.1       | 0/261888        | 1475.3
47008  none             | 22816     15         0.0007      0.1       | 261850/261850   | 3379.0
47008  dontcache        | 22816     15         0.0007      0.1       | 1/261850        | 3053.8
47008  dsync            | 22816     15         0.0007      0.1       | 261850/261850   | 1205.3
47008  dontcache,dsync  | 22816     15         0.0007      0.1       | 1/261850        | 1173.4
6000   none             | 178944    15         0.0001      0.1       | 262125/262125   | 1923.5
6000   dontcache        | 178944    15         0.0001      0.1       | 0/262125        | 457.5
6000   dsync            | 178944    15         0.0001      0.1       | 262125/262125   | 204.8
6000   dontcache,dsync  | 178944    26         0.0001      0.1       | 11/262125       | 200.0

(The rates are from a 4 KiB-page arm64 VM and will differ elsewhere;
 the reads per write should not.)

The defaults are the cover letter's: 32 threads, 1 GiB per run, record
sizes 49152, 47008 and 6000 bytes, and flags none, dontcache, dsync and
dontcache,dsync (NT, TOTAL, RSS and FLAGSETS override them).  Run it
once on a kernel without the series and once with it.  What to look
for:

- 47008 and 6000 with dontcache, with or without dsync: about one read
  per write without the series, none with it.  These are the table's
  rows.
- 49152 with dontcache: the control.  Its records cover only whole
  pages, so it reads nothing either way.
- none and dsync: plain buffered writes.  They read nothing either way,
  and leave the whole file resident; the dontcache rows leave next to
  none.

Thanks,
Mike

/* dcwrite: interleaved misaligned buffered writers, no NFS.  N threads; thread
 * r's record s lands at (s*N + r)*RECSZ, the iorhard geometry, so each record
 * shares its first and last page with the records of two other threads.
 * Each record is one pwritev2() with FLAGS (RWF_DONTCACHE, RWF_DSYNC, ...).
 * With "direct" the file is opened O_DIRECT and the buffer is page aligned.
 * Reports the write phase alone and, after a final fsync(), "to stable".
 *
 * usage: dcwrite FILE NTHREADS RECSZ TOTALBYTES FLAGS
 *   FLAGS: comma list of none,dontcache,dsync,direct
 * Exit 1 at the first failed or short write, or a failed fsync(). */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/uio.h>
#include <time.h>
#include <unistd.h>
#ifndef RWF_DONTCACHE
#define RWF_DONTCACHE 0x00000080
#endif

static int N, fd, flags, odirect; static long RECSZ, NREC; static volatile int failed;

static void *writer(void *arg)
{
	long r = (long)arg;
	char *buf = NULL;
	if (posix_memalign((void **)&buf, 4096, RECSZ)) { failed = 1; return NULL; }
	memset(buf, 'A' + r % 26, RECSZ);
	for (long s = 0; s < NREC && !failed; s++) {
		off_t off = (off_t)(s * N + r) * RECSZ;
		struct iovec iov = { buf, RECSZ };
		ssize_t n = pwritev2(fd, &iov, 1, off, flags);
		if (n != RECSZ) {
			fprintf(stderr, "thread %ld: pwritev2 at %lld: %s\n", r, (long long)off,
				n < 0 ? strerror(errno) : "short write");
			failed = 1;
		}
	}
	free(buf);
	return NULL;
}

int main(int argc, char **argv)
{
	if (argc != 6) { fprintf(stderr, "usage: %s FILE NTHREADS RECSZ TOTALBYTES FLAGS\n", argv[0]); return 2; }
	N = atoi(argv[2]); RECSZ = atol(argv[3]);
	if (N < 1 || N > 1024 || RECSZ < 1) { fprintf(stderr, "bad NTHREADS or RECSZ\n"); return 2; }
	NREC = atol(argv[4]) / RECSZ / N;
	for (char *t = strtok(argv[5], ","); t; t = strtok(NULL, ","))
		if (!strcmp(t, "dontcache")) flags |= RWF_DONTCACHE;
		else if (!strcmp(t, "dsync")) flags |= RWF_DSYNC;
		else if (!strcmp(t, "direct")) odirect = O_DIRECT;
		else if (strcmp(t, "none")) { fprintf(stderr, "bad flag %s\n", t); return 2; }
	fd = open(argv[1], O_WRONLY | O_CREAT | O_TRUNC | odirect, 0644);
	if (fd < 0) { perror(argv[1]); return 1; }
	pthread_t *t = calloc(N, sizeof(*t));
	struct timespec a, b; clock_gettime(CLOCK_MONOTONIC, &a);
	for (long r = 0; r < N; r++)
		if (pthread_create(&t[r], NULL, writer, (void *)r)) { perror("pthread_create"); return 1; }
	for (int r = 0; r < N; r++) pthread_join(t[r], NULL);
	clock_gettime(CLOCK_MONOTONIC, &b);
	int frc = fsync(fd);
	struct timespec c; clock_gettime(CLOCK_MONOTONIC, &c);
	double sec = (b.tv_sec - a.tv_sec) + (b.tv_nsec - a.tv_nsec) / 1e9;
	double ssec = (c.tv_sec - a.tv_sec) + (c.tv_nsec - a.tv_nsec) / 1e9;
	double mib = (double)NREC * N * RECSZ / 1048576;
	printf("dcwrite: %d threads x %ld records x %ld bytes = %.1f MiB in %.2fs (%.1f MiB/s) flags=0x%x%s; to stable %.2fs (%.1f MiB/s)\n",
	       N, NREC, RECSZ, mib, sec, mib / sec, flags, odirect ? " O_DIRECT" : "", ssec, mib / ssec);
	if (frc) perror("fsync");
	if (close(fd)) { perror("close"); frc = -1; }
	return (failed || frc) ? 1 : 0;
}

#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# dc-ab.sh OUTDIR [DCWRITE] - RWF_DONTCACHE shared-page test, no NFS.
#
# For each record size and flag set: a fresh XFS on an emulated 4Kn NVMe
# namespace (the in-kernel NVMe target's file backend on a tmpfs image,
# attached over nvme-loop, so the device has NVMe's queue limits and a
# 4096-byte logical block), then NT dcwrite threads writing TOTAL bytes as
# interleaved records.  It reports the device's 4 KiB reads per write, from
# /sys/block/<dev>/stat around the write and a final sync, the file's
# resident pages after the sync (fincore), and the write rate.
#
# Needs root, the nvmet and nvme-loop modules, nvme-cli, xfsprogs, util-linux
# (fincore), and SIZE (default 4G) free in /dev/shm.  Build dcwrite first:
#   cc -O2 -pthread -o dcwrite dcwrite.c
#
# Environment: NT (32), TOTAL (1 GiB), RSS ("49152 47008 6000"),
# FLAGSETS ("none dontcache dsync dontcache,dsync"), SIZE (4G),
# IMG (/dev/shm/dc-ab.img), MNT (/mnt/dc-ab), PORT (nvmet port id, 9).
set -u
OUT=${1:?usage: dc-ab.sh OUTDIR [DCWRITE]}; DCW=$(realpath "${2:-./dcwrite}")
NT=${NT:-32}; TOTAL=${TOTAL:-1073741824}; SIZE=${SIZE:-4G}
RSS=${RSS:-"49152 47008 6000"}
FLAGSETS=${FLAGSETS:-"none dontcache dsync dontcache,dsync"}
IMG=${IMG:-/dev/shm/dc-ab.img}; MNT=${MNT:-/mnt/dc-ab}; PORT=${PORT:-9}
NQN=dc-ab-test; CFS=/sys/kernel/config/nvmet
SUB=$CFS/subsystems/$NQN; PRT=$CFS/ports/$PORT

die() { echo "dc-ab.sh: $*" >&2; down; exit 2; }
nsdev() {
	local d
	for d in /sys/block/nvme*n*; do
		# not a multipath path node (nvmeXcYnZ), which has no /dev entry
		[[ $(basename "$d") =~ ^nvme[0-9]+n[0-9]+$ ]] || continue
		[ "$(cat "$d/device/subsysnqn" 2>/dev/null)" = $NQN ] &&
			{ basename "$d"; return; }
	done
}
up() {
	truncate -s "$SIZE" "$IMG" || die "cannot create $IMG"
	mkdir "$SUB" || die "cannot create nvmet subsystem $NQN"
	echo 1 > "$SUB/attr_allow_any_host"
	mkdir "$SUB/namespaces/1"
	echo -n "$IMG" > "$SUB/namespaces/1/device_path"
	# the image is in RAM already: no O_DIRECT below the emulated device
	echo 1 > "$SUB/namespaces/1/buffered_io"
	echo 1 > "$SUB/namespaces/1/enable" || die "cannot enable the namespace"
	mkdir "$PRT" || die "nvmet port $PORT is in use: set PORT"
	echo -n loop > "$PRT/addr_trtype"
	# nvme-loop sends a connect without an address to the first loop port,
	# which need not be this one
	echo -n $NQN > "$PRT/addr_traddr"
	ln -s "$SUB" "$PRT/subsystems/$NQN"
	nvme connect -t loop -a $NQN -n $NQN > /dev/null || die "nvme connect failed"
	local i
	for i in $(seq 20); do DEV=$(nsdev); [ -n "$DEV" ] && break; sleep 0.5; done
	[ -n "$DEV" ] || die "the namespace did not appear"
	udevadm settle 2> /dev/null
	mkfs.xfs -q -f "/dev/$DEV" || die "mkfs.xfs failed"
	mkdir -p "$MNT"
	mount -t xfs "/dev/$DEV" "$MNT" || die "mount failed"
}
down() {
	umount "$MNT" 2> /dev/null
	nvme disconnect -n $NQN > /dev/null 2>&1
	rm -f "$PRT/subsystems/$NQN" 2> /dev/null
	rmdir "$PRT" 2> /dev/null
	[ -d "$SUB" ] && echo 0 > "$SUB/namespaces/1/enable" 2> /dev/null
	rmdir "$SUB/namespaces/1" "$SUB" 2> /dev/null
	rm -f "$IMG"
}

[ "$(id -u)" = 0 ] || { echo "dc-ab.sh: run as root" >&2; exit 2; }
[ -x "$DCW" ] || { echo "dc-ab.sh: build dcwrite first: cc -O2 -pthread -o dcwrite dcwrite.c" >&2; exit 2; }
modprobe nvmet && modprobe nvme-loop || exit 2
[ -d "$SUB" ] && { echo "dc-ab.sh: $SUB exists: a run is in progress or was left behind" >&2; exit 2; }
mkdir -p "$OUT"
echo "kernel $(uname -r)" > "$OUT/env.txt"
printf '%-6s %-16s | %-9s %-10s %-11s %-9s | %-15s | %s\n' \
	rs flags writes 4K-reads reads/write READ-MiB resident-pages MiB/s > "$OUT/table.txt"
for rs in $RSS; do for fl in $FLAGSETS; do
	d=$OUT/$rs-${fl//,/+}; mkdir -p "$d"
	DEV=; up
	F=$MNT/dc.bin
	sync; echo 3 > /proc/sys/vm/drop_caches
	read -r _ _ s0 _ < "/sys/block/$DEV/stat"
	"$DCW" "$F" "$NT" "$rs" "$TOTAL" "$fl" > "$d/dcwrite.txt" 2>&1; rc=$?
	sync
	read -r _ _ s1 _ < "/sys/block/$DEV/stat"
	res=$(fincore -b -n -r -o RES "$F"); pages=$(( ($(stat -c %s "$F") + 4095) / 4096 ))
	nrec=$(( TOTAL / rs / NT * NT ))
	mbs=$(grep -o '([0-9.]* MiB/s' "$d/dcwrite.txt" | head -1 | tr -d '(' | awk '{print $1}')
	# data reads in 4 KiB blocks, from sectors read (a read request that
	# moves no sectors, as a flush can show up, adds nothing here)
	rd=$(( (s1 - s0) * 512 / 4096 ))
	rmib=$(awk -v s=$((s1 - s0)) 'BEGIN { printf "%.1f", s * 512 / 1048576 }')
	rpw=$(awk -v r=$rd -v w=$nrec 'BEGIN { printf "%.4f", r / w }')
	[ $rc -ne 0 ] && mbs="rc=$rc"
	printf '%-6s %-16s | %-9s %-10s %-11s %-9s | %-15s | %s\n' $rs $fl $nrec $rd \
		$rpw $rmib "$(( (res + 4095) / 4096 ))/$pages" "${mbs:-?}" >> "$OUT/table.txt"
	down
done; done
cat "$OUT/table.txt"
