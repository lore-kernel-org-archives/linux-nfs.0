Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758721Ab0EUXAN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 19:00:13 -0400
Date: Fri, 21 May 2010 19:00:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tao Guo <glorioustao@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Message-ID: <20100521230011.GI13227@fieldses.org>
References: <20100517135341.GA30737@fieldses.org> <4BF151A7.1070003@panasas.com> <20100517145311.GJ30737@fieldses.org> <20100517165302.GL30737@fieldses.org> <AANLkTilUpAHrtHH8pauvYrAuD3rWgj7aDmrTOzrmU-h5@mail.gmail.com> <20100518162005.GI17823@fieldses.org> <AANLkTik9L15tqpSboBpb9cSTy3hVPLEK487w94pEbLrS@mail.gmail.com> <20100519163632.GL4581@fieldses.org> <20100519213849.GR9720@fieldses.org> <AANLkTikEOhpGbCEAkxvDC93B1lM6d_htL_TOfjFOpAsD@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTikEOhpGbCEAkxvDC93B1lM6d_htL_TOfjFOpAsD@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 20, 2010 at 01:44:13PM +0800, Tao Guo wrote:
> Hi, Fields
> I used the connectathon general test with my latest code, and it
> passed the tests.
> Can you just try the two patches I have sent in the mailing list to
> see if it helps?

GENERAL TESTS: directory /mnt/TMP
if test ! -x runtests; then chmod a+x runtests; fi
cd /mnt/TMP; rm -f Makefile runtests runtests.wrk *.sh *.c mkdummy
rmdummy nroff.in makefile.tst
cp Makefile runtests runtests.wrk *.sh *.c mkdummy rmdummy nroff.in
makefile.tst /mnt/TMP

Small Compile
/usr/lib/gcc/x86_64-linux-gnu/4.4.1/../../../../lib/crt1.o: In function
`_start':
/build/buildd/eglibc-2.10.1/csu/../sysdeps/x86_64/elf/start.S:109:
undefined reference to `main'
collect2: ld returned 1 exit status
Command exited with non-zero status 1
0.02user 0.05system 0:00.12elapsed 66%CPU (0avgtext+0avgdata
22464maxresident)k
0inputs+0outputs (0major+4946minor)pagefaults 0swaps
general tests failed

I don't know what's going on there; sounds like data corruption?

--b.
