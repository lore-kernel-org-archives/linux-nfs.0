Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:57507 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426Ab3I3R3q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 13:29:46 -0400
Message-ID: <5249B21E.70603@itwm.fraunhofer.de>
Date: Mon, 30 Sep 2013 19:17:18 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: Miklos Szeredi <miklos@szeredi.hu>, Ric Wheeler <rwheeler@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
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
References: <20130930143432.GG16579@fieldses.org> <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com> <52499026.3090802@redhat.com> <CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com> <52498AA8.2090204@redhat.com> <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com> <52498DB6.7060901@redhat.com> <CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com> <52498F68.8050200@redhat.com> <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com> <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>
In-Reply-To: <20130930163159.GA14242@tucsk.piliscsaba.szeredi.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/30/2013 06:31 PM, Miklos Szeredi wrote:
> Here's an example "cp" app using direct splice (and without fallback to
> non-splice, which is obviously required unless the kernel is known to support
> direct splice).
>
> Untested, but trivial enough...
>
> The important part is, I think, that the app must not assume that the kernel can
> complete the request in one go.
>
> Thanks,
> Miklos
>
> ----
> #define _GNU_SOURCE
>
> #include <stdio.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <limits.h>
> #include <sys/stat.h>
> #include <err.h>
>
> #ifndef SPLICE_F_DIRECT
> #define SPLICE_F_DIRECT        (0x10)  /* neither splice fd is a pipe */
> #endif
>
> int main(int argc, char *argv[])
> {
> 	struct stat stbuf;
> 	int in_fd;
> 	int out_fd;
> 	int res;
> 	off_t off;

off_t off = 0;

>
> 	if (argc != 3)
> 		errx(1, "usage: %s from to", argv[0]);
>
> 	in_fd = open(argv[1], O_RDONLY);
> 	if (in_fd == -1)
> 		err(1, "opening %s", argv[1]);
>
> 	res = fstat(in_fd, &stbuf);
> 	if (res == -1)
> 		err(1, "fstat");
>
> 	out_fd = open(argv[2], O_CREAT | O_WRONLY | O_TRUNC, stbuf.st_mode);
> 	if (out_fd == -1)
> 		err(1, "opening %s", argv[2]);
>
> 	do {
> 		off_t in_off = off, out_off = off;
> 		ssize_t rres;
>
> 		rres = splice(in_fd, &in_off, out_fd, &out_off, SSIZE_MAX,
> 			     SPLICE_F_DIRECT);
> 		if (rres == -1)
> 			err(1, "splice");
> 		if (rres == 0)
> 			break;
>
> 		off += rres;
> 	} while (off < stbuf.st_size);
>
> 	res = close(in_fd);
> 	if (res == -1)
> 		err(1, "close");
>
> 	res = fsync(out_fd);
> 	if (res == -1)
> 		err(1, "fsync");
>
> 	res = close(out_fd);
> 	if (res == -1)
> 		err(1, "close");
>
> 	return 0;
> }


It would be nice if there would be way if the file system would get a 
hint that the target file is supposed to be copy of another file. That 
way distributed file systems could also create the target-file with the 
correct meta-information (same storage targets as in-file has).
Well, if we cannot agree on that, file system with a custom protocol at 
least can detect from 0 to SSIZE_MAX and then reset metadata. I'm not 
sure if this would work for pNFS, though.


Bernd



