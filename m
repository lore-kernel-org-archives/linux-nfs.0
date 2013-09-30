Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f172.google.com ([209.85.215.172]:51024 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938Ab3I3Qb2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 12:31:28 -0400
Received: by mail-ea0-f172.google.com with SMTP id r16so2826978ead.31
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 09:31:27 -0700 (PDT)
Date: Mon, 30 Sep 2013 18:31:59 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zach Brown <zab@redhat.com>, Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>
References: <20130930143432.GG16579@fieldses.org>
 <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
 <52499026.3090802@redhat.com>
 <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
 <52498AA8.2090204@redhat.com>
 <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>
 <52498DB6.7060901@redhat.com>
 <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
 <52498F68.8050200@redhat.com>
 <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's an example "cp" app using direct splice (and without fallback to
non-splice, which is obviously required unless the kernel is known to support
direct splice).

Untested, but trivial enough...

The important part is, I think, that the app must not assume that the kernel can
complete the request in one go.

Thanks,
Miklos

----
#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <sys/stat.h>
#include <err.h>

#ifndef SPLICE_F_DIRECT
#define SPLICE_F_DIRECT        (0x10)  /* neither splice fd is a pipe */
#endif

int main(int argc, char *argv[])
{
	struct stat stbuf;
	int in_fd;
	int out_fd;
	int res;
	off_t off;

	if (argc != 3)
		errx(1, "usage: %s from to", argv[0]);

	in_fd = open(argv[1], O_RDONLY);
	if (in_fd == -1)
		err(1, "opening %s", argv[1]);

	res = fstat(in_fd, &stbuf);
	if (res == -1)
		err(1, "fstat");

	out_fd = open(argv[2], O_CREAT | O_WRONLY | O_TRUNC, stbuf.st_mode);
	if (out_fd == -1)
		err(1, "opening %s", argv[2]);

	do {
		off_t in_off = off, out_off = off;
		ssize_t rres;

		rres = splice(in_fd, &in_off, out_fd, &out_off, SSIZE_MAX,
			     SPLICE_F_DIRECT);
		if (rres == -1)
			err(1, "splice");
		if (rres == 0)
			break;

		off += rres;
	} while (off < stbuf.st_size);

	res = close(in_fd);
	if (res == -1)
		err(1, "close");

	res = fsync(out_fd);
	if (res == -1)
		err(1, "fsync");

	res = close(out_fd);
	if (res == -1)
		err(1, "close");

	return 0;
}
