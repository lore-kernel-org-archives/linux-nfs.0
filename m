From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 01/03] Add splice02 as a new syscall test in LTP [LKML
	Subject: nfs: add support for splice writes]
Date: Mon, 13 Apr 2009 20:01:30 +0200
Message-ID: <20090413180130.GA5178@kernel.dk>
References: <20090413125029.23749.31305.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Suresh Jayaraman <sjayaraman@suse.de>, linux-nfs@vger.kernel.org,
	ltp-list <ltp-list-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org>,
	"Deepakraj B. Himavantharaj" <deepakraj@in.ibm.com>
To: Manas K Nayak <maknayak@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:50308 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbZDMSBc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2009 14:01:32 -0400
In-Reply-To: <20090413125029.23749.31305.sendpatchset-NRFfyExJdYpgXGGE5LP+UZlqa2bBAFbm0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 13 2009, Manas K Nayak wrote:
> Hi Jens,
> 
> >This patch attempts to add splice writes support. In essence, it just
> >calls generic_file_splice_write() after doing a little sanity check.
> >This would allow LTTng users that are using NFS to store trace data.
> >There could be more applications that could be benefitted too.
> >
> >I have tested this using the Jens' test program and have found no
> >real issues. The test program is inlined below:
> >
> >/*
> > * splice-out.c: Splice stdout to file
> > */
> >#include <stdio.h>
> >#include <stdlib.h>
> >#include <unistd.h>
> >#include <fcntl.h>
> >
> >#define SPLICE_SIZE (64*1024)
> >
> >int main(int argc, char *argv[])
> >{
> >       int fd;
> >
> >       if (argc < 2) {
> >               printf("%s: outfile\n", argv[0]);
> >               return 1;
> >       }
> >
> >       fd = open(argv[1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
> >       if (fd < 0) {
> >               perror("open");
> >               return 1;
> >       }
> >
> >       do {
> >               int ret = splice(STDIN_FILENO, NULL, fd, NULL, SPLICE_SIZE, 0);
> >
> >               if (ret < 0) {
> >                       perror("splice");
> >                       break;
> >               } else if (ret < SPLICE_SIZE)
> >                       break;
> >       } while (1);
> >
> >       close(fd);
> >       return 0;
> >}
> >
> >Compile with -D _GNU_SOURCE and do something like:
> >       echo "some stuff" | ./splice-out <outfile>
> >
> >
> 
> I picked up this above test program written by you (and referred
> by Suresh) and ported this to LTP under GPL. If you do not have
> any objection(s), can we contribute this to LTP ? The following
> patch will do exactly that.

Certainly, go ahead!

> 
> Original-Author: Jens Axboe <axboe@kernel.dk>,
> Ported-To-LTP:By: Manas K Nayak <maknayak@in.ibm.com>
> ---
> 
> --- ltp-full-20090331.orig/testcases/kernel/syscalls/splice/splice02.c	1970-01-01 05:30:00.000000000 +0530
> +++ ltp-full-20090331/testcases/kernel/syscalls/splice/splice02.c	2009-04-13 16:04:21.000000000 +0530
> @@ -0,0 +1,145 @@
> +/******************************************************************************/
> +/* Copyright (c) Jens Axboe <axboe@kernel.dk>, 2009                           */
> +/*                                                                            */
> +/* LKML Reference: http://lkml.org/lkml/2009/4/2/55                           */
> +/*                                                                            */
> +/* This program is free software;  you can redistribute it and/or modify      */
> +/* it under the terms of the GNU General Public License as published by       */
> +/* the Free Software Foundation; either version 2 of the License, or          */
> +/* (at your option) any later version.                                        */
> +/*                                                                            */
> +/* This program is distributed in the hope that it will be useful,            */
> +/* but WITHOUT ANY WARRANTY;  without even the implied warranty of            */
> +/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See                  */
> +/* the GNU General Public License for more details.                           */
> +/*                                                                            */
> +/* You should have received a copy of the GNU General Public License          */
> +/* along with this program;  if not, write to the Free Software               */
> +/* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA    */
> +/*                                                                            */
> +/******************************************************************************/
> +/******************************************************************************/
> +/*                                                                            */
> +/* File:        splice02.c                                                    */
> +/*                                                                            */
> +/* Description: This tests the splice() syscall                               */
> +/*                                                                            */
> +/* Usage:  <for command-line>                                                 */
> +/* echo "Test splice()" > <outfile>; splice02 <outfile>                       */
> +/*                                                                            */
> +/* Total Tests: 1                                                             */
> +/*                                                                            */
> +/* Test Name:   splice02                                                      */
> +/******************************************************************************/
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <fcntl.h>
> +
> +
> +/* Harness Specific Include Files. */
> +#include "test.h"
> +#include "usctest.h"
> +#include "linux_syscall_numbers.h"
> +
> +/* Extern Global Variables */
> +extern int Tst_count;           /* counter for tst_xxx routines.         */
> +extern char *TESTDIR;           /* temporary dir created by tst_tmpdir() */
> +
> +/* Global Variables */
> +char *TCID = "splice02";  /* Test program identifier.*/
> +int  testno;
> +int  TST_TOTAL = 1;                   /* total number of tests in this file.   */
> +
> +/* Extern Global Functions */
> +/******************************************************************************/
> +/*                                                                            */
> +/* Function:    cleanup                                                       */
> +/*                                                                            */
> +/* Description: Performs all one time clean up for this test on successful    */
> +/*              completion,  premature exit or  failure. Closes all temporary */
> +/*              files, removes all temporary directories exits the test with  */
> +/*              appropriate return code by calling tst_exit() function.       */
> +/*                                                                            */
> +/* Input:       None.                                                         */
> +/*                                                                            */
> +/* Output:      None.                                                         */
> +/*                                                                            */
> +/* Return:      On failure - Exits calling tst_exit(). Non '0' return code.   */
> +/*              On success - Exits calling tst_exit(). With '0' return code.  */
> +/*                                                                            */
> +/******************************************************************************/
> +extern void cleanup() {
> +        /* Remove tmp dir and all files in it */
> +        TEST_CLEANUP;
> +        tst_rmdir();
> +
> +        /* Exit with appropriate return code. */
> +        tst_exit();
> +}
> +
> +/* Local  Functions */
> +/******************************************************************************/
> +/*                                                                            */
> +/* Function:    setup                                                         */
> +/*                                                                            */
> +/* Description: Performs all one time setup for this test. This function is   */
> +/*              typically used to capture signals, create temporary dirs      */
> +/*              and temporary files that may be used in the course of this    */
> +/*              test.                                                         */
> +/*                                                                            */
> +/* Input:       None.                                                         */
> +/*                                                                            */
> +/* Output:      None.                                                         */
> +/*                                                                            */
> +/* Return:      On failure - Exits by calling cleanup().                      */
> +/*              On success - returns 0.                                       */
> +/*                                                                            */
> +/******************************************************************************/
> +void setup() {
> +        /* Capture signals if any */
> +        /* Create temporary directories */
> +        TEST_PAUSE;
> +        tst_tmpdir();
> +}
> +
> +#define SPLICE_SIZE (64*1024)
> +
> +int main(int ac, char **av) {
> +	int fd = 0;
> +	int ret = 0;
> +	
> +        setup();
> +
> +        if (ac < 2 ) {
> +            tst_resm(TFAIL, "%s failed - Usage: %s outfile", TCID, av[0]);
> +            tst_exit();
> +	}
> +	fd=open(av[1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
> +	if(fd < 0 ) {
> +           tst_resm(TFAIL, "%s failed - errno = %d : %s", TCID, TEST_ERRNO, strerror(TEST_ERRNO));
> +	   cleanup();
> +	   tst_exit();
> +	}
> +			
> +        do {
> +	    ret = splice(STDIN_FILENO, NULL, fd, NULL, SPLICE_SIZE, 0);
> +	    if (ret < 0) {
> +            	tst_resm(TFAIL, "%s failed - errno = %d : %s",TCID, TEST_ERRNO, strerror(TEST_ERRNO));
> +	        cleanup();
> +		tst_exit();
> +	    } else
> +            if (ret < SPLICE_SIZE){
> +	        cleanup();
> +	        tst_exit();
> +	    }
> +	} while(1);
> +
> +	close(fd);
> +        tst_resm(TPASS, "splice() system call Passed");
> +        tst_exit();
> +}
> +
> --- ltp-full-20090331.orig/runtest/syscalls	2009-04-13 15:12:15.000000000 +0530
> +++ ltp-full-20090331/runtest/syscalls	2009-04-13 16:10:26.000000000 +0530
> @@ -1030,6 +1030,8 @@ sockioctl01 sockioctl01
>  
>  #splice test
>  splice01 splice01
> +splice02 echo "Test splice02()" > splice02-temp; splice02 splice02-temp
> +
>  tee01 tee01
>  
>  stat01 stat01
> 
> ---
> Regards--
> Manas
> 

-- 
Jens Axboe

