Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38551 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbbCQVgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 17:36:54 -0400
Date: Tue, 17 Mar 2015 17:36:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150317213654.GE29843@fieldses.org>
References: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1426540688-32095-4-git-send-email-Anna.Schumaker@Netapp.com>
 <20150317195633.GC29843@fieldses.org>
 <20150317200738.GD29843@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150317200738.GD29843@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2015 at 04:07:38PM -0400, J. Bruce Fields wrote:
> On Tue, Mar 17, 2015 at 03:56:33PM -0400, J. Bruce Fields wrote:
> > On Mon, Mar 16, 2015 at 05:18:08PM -0400, Anna Schumaker wrote:
> > > This patch implements sending an array of segments back to the client.
> > > Clients should be prepared to handle multiple segment reads to make this
> > > useful.  We try to splice the first data segment into the XDR result,
> > > and remaining segments are encoded directly.
> > 
> > I'm still interested in what would happen if we started with an
> > implementation like:
> > 
> > 	- if the entire requested range falls within a hole, return that
> > 	  single hole.
> > 	- otherwise, just treat the thing as one big data segment.
> > 
> > That would provide a benefit in the case there are large-ish holes
> > with minimal impact otherwise.
> > 
> > (Though patches for full support are still useful even if only for
> > client-testing purposes.)
> 
> Also, looks like
> 
> 	xvs_io -c "fiemap -v" <file>
> 
> will give hole sizes for a given <file>.  (Thanks, esandeen.)  Running
> that on a few of my test vm images shows a fair number of large
> (hundreds of megs) files, which suggests identifying only >=rwsize holes
> might still be useful.

Just for fun.... I wrote the following test program and ran it on my
collection of testing vm's.  Some looked like this:

	f21-1.qcow2
	144784 -rw-------. 1 qemu qemu 8591507456 Mar 16 10:13 f21-1.qcow2
	total hole bytes:      8443252736 (98%)
	in aligned 1MB chunks: 8428453888 (98%)

So, basically, read_plus would save transferring most of the data even
when only handling 1MB holes.

But some looked like this:

	501524 -rw-------. 1 qemu qemu 8589934592 May 20  2014 rhel6-1-1.img
	total hole bytes:      8077516800 (94%)
	in aligned 1MB chunks: 0 (0%)

So the READ_PLUS that caught every hole might save a lot, the one that
only caught 1MB holes wouldn't help at all.

And there were lots of examples in between those two extremes.

(But, check my math, I haven't tested this carefully.)

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

do_stats(off_t hole_start, off_t hole_end)
{
	off_t hole_start_up, hole_end_down;

	hole_start_up = round_up(hole_start, 1024*1024);
	hole_end_down = round_down(hole_end, 1024*1024);

	hbytes += hole_end - hole_start;
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
	printf("total hole bytes:      %ld (%.0f%)\n", hbytes,
				100 * (float)hbytes/hole_end);
	printf("in aligned 1MB chunks: %ld (%.0f%)\n", rplusbytes,
				100 * (float)rplusbytes/hole_end);
}
