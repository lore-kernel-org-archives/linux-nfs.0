Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:57263
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753565Ab1G0SLR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:11:17 -0400
Date: Wed, 27 Jul 2011 14:11:11 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
Message-ID: <20110727181111.GA23009@infradead.org>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan>
 <20110727160752.GC974@fieldses.org>
 <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
In-Reply-To: <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Justin,

can you please run the attached test program on the affected directory
on the server, and see if you see duplicates in the d_off colum.  Unless
you have privacy concerns I would also love to see the full output.


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="getdents.c"

#define _GNU_SOURCE

#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/syscall.h>

#define handle_error(msg) \
               do { perror(msg); exit(EXIT_FAILURE); } while (0)

struct linux_dirent64 {
	unsigned long long d_ino;
	long long d_off;
	unsigned short d_reclen;
	unsigned char d_type;
	char d_name[];
};

#define BUF_SIZE 131072

int main(int argc, char *argv[])
{
	int fd, nread;
	char buf[BUF_SIZE];
	struct linux_dirent64 *d;
	int bpos;

	fd = open(argc > 1 ? argv[1] : ".", O_RDONLY | O_DIRECTORY);
	if (fd == -1)
		handle_error("open");

	for (;;) {
		nread = syscall(SYS_getdents64, fd, buf, BUF_SIZE);
		if (nread == -1)
			handle_error("getdents");

		if (nread == 0)
			break;

		printf("--------------- nread=%d ---------------\n", nread);
		printf("i-node#          type  d_reclen  d_off   d_name\n");
		for (bpos = 0; bpos < nread;) {
			d = (struct linux_dirent64 *)(buf + bpos);
			printf("%16lld  ", d->d_ino);
			printf("%4d %10lld  %s\n", d->d_reclen,
			       d->d_off, d->d_name);
			bpos += d->d_reclen;
		}
	}

	exit(EXIT_SUCCESS);
}

--ibTvN161/egqYuK8--
