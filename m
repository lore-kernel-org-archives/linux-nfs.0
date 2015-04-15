Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35285 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756197AbbDOUAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2015 16:00:17 -0400
Date: Wed, 15 Apr 2015 16:00:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, Marc Eshel <eshel@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150415200016.GB31407@fieldses.org>
References: <55142FB4.2070408@Netapp.com>
 <CAHQdGtS_VuBOzRZjsiYdjZS8qMj2Sw65BYdFmWWf-LJhQL6yOg@mail.gmail.com>
 <5515A9C8.6090400@Netapp.com>
 <CAHQdGtRaUYxU2JAAWErH7FT=Gy5JLzAKi-RtqqBSkNFZrhaB9Q@mail.gmail.com>
 <5515C1BF.8000907@Netapp.com>
 <20150327205414.GD27889@fieldses.org>
 <5515C3BE.3040807@Netapp.com>
 <20150327210839.GE27889@fieldses.org>
 <552EBCB2.1040609@Netapp.com>
 <20150415195614.GA31407@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150415195614.GA31407@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 15, 2015 at 03:56:14PM -0400, J. Bruce Fields wrote:
> On Wed, Apr 15, 2015 at 03:32:02PM -0400, Anna Schumaker wrote:
> > I just ran some more tests comparing the directio case across
> > different filesystem types.  These tests used three 1G files:  100%
> > data, 100% hole, and mixed file with alternating 4k data and hole
> > segments.  The mixed case seems to be consistently slower compared to
> > NFS v4.1, and I'm at a loss for anything I could do to make it faster.
> > Here are my numbers:
> 
> Have you tried the implementation we discussed that always returns a
> single segment covering the whole requested range, by treating holes as
> data if necessary when they don't cover the whole range?
> 
> (Also: I assume it's the same as before, but: when you post test
> results, could you repost if necessary:
> 
> 	- what the actual test is
> 	- what the hardware/software setup is on client and server
> 
> so that we have reproduceable results for posterity's sake.)
> 
> Interesting that "Mixed" is a little slower even before READ_PLUS.
> 
> And I guess we should really report this to ext4 people, looks like they
> may have a bug.

FWIW, this is what I was using to test SEEK_HOLE/SEEK_DATA and map out
holes on files on my local disk.  Might be worth checking whether the
ext4 slowdowns are reproduceable just with something like this, to rule
out protocol problems.

--b.

#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h> 
#include <errno.h>
#include <err.h>

long round_up(long n, long b)
{
	return ((n + b - 1)/b) * b;
}

long round_down(long n, long b)
{
	return (n/b) * b;
}

long hbytes = 0;
long rplusbytes = 0;
long num_holes = 0;

do_stats(off_t hole_start, off_t hole_end)
{
	off_t hole_start_up, hole_end_down;

	hole_start_up = round_up(hole_start, 1024*1024);
	hole_end_down = round_down(hole_end, 1024*1024);

	hbytes += hole_end - hole_start;
	if (hole_start < hole_end)
		num_holes++;
	if (hole_start_up < hole_end_down)
		rplusbytes += hole_end_down - hole_start_up;
}

int main(int argc, char *argv[])
{
	off_t hole_start, hole_end;
	int fd;
	char *name;

	/* Map out holes with SEEK_HOLE, SEEK_DATA */
	/* Useful statistics:
	 * 	- what percentage of file is in holes?
	 * 	- what percentage of file would be skipped if we read it
	 * 	  sequentially in 1MB chunks?
	 */

	if (argc != 2)
		errx(1, "usage: %s <filename>\n", argv[0]);
	name = argv[1];
	fd = open(name, O_RDONLY);
	if (fd == -1)
		err(1, "open");

	hole_end = 0;
	while (1) {
		hole_start = lseek(fd, hole_end, SEEK_HOLE);
		if (hole_start == -1)
			err(1, "lseek");
		hole_end = lseek(fd, hole_start, SEEK_DATA);
		if (hole_end == -1) {
			if (errno == ENXIO)
				break;
			err(1, "lseek");
		}
		do_stats(hole_start, hole_end);
	}
	hole_end = lseek(fd, 0, SEEK_END);
	do_stats(hole_start, hole_end);
	printf("%ld holes\n", num_holes);
	printf("total hole bytes:      %ld (%.0f%)\n", hbytes,
				100 * (float)hbytes/hole_end);
	printf("in aligned 1MB chunks: %ld (%.0f%)\n", rplusbytes,
				100 * (float)rplusbytes/hole_end);
}
