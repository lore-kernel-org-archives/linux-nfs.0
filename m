Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gws06.hcl.com ([203.105.185.25]:36365 "EHLO GWS06.hcl.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751905AbcLHPz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 10:55:57 -0500
From: Brian Cowan <brian.cowan@hcl.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: FW: File lock performance over NFSv4 degrades dramatically when
 lock contention is present.
Date: Thu, 8 Dec 2016 15:55:45 +0000
Message-ID: <HK2PR0401MB1570E4FEB293CA7CECA082D4FE840@HK2PR0401MB1570.apcprd04.prod.outlook.com>
References: <HK2PR0401MB157008D9798FDBF609C616EEFE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
 <HK2PR0401MB1570ACF852B10ADA56DB0059FE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
 <20161206204745.GB1203@fieldses.org>
In-Reply-To: <20161206204745.GB1203@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, all, when I use the 4.9.0-rc8 kernel, the long lock times when contention occurs is still present. In a 5 minute run, I have 2 lock waits > 15 seconds and quite a few others over 1 sec. 

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Tuesday, December 6, 2016 3:48 PM
To: Brian Cowan <brian.cowan@hcl.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: FW: File lock performance over NFSv4 degrades dramatically when lock contention is present.

On Tue, Dec 06, 2016 at 03:58:52PM +0000, Brian Cowan wrote:
> On moving an application that uses file locking from NFSv3 to NFSV4, we found that file lock/unlock times can vary wildly when lock contention is present. Our application has multiple files that have to be locked in the remote filesystem. When multiple instances (as few as 2) of the application components are running and sharing these files we are seeing lock delays in seconds as opposed to milli/microseconds. 

NFSv4.0 clients poll for contended locks--so after the lock's released, the server just sits there waiting for some client to retry the lock.
And I don't recall exactly but seconds sounds about right for those retry timeouts.

NFSv3 on the other hand (well, actually NLM, the sideband locking
protocol) has callbacks that allows the server to call back to clients waiting for contended locks.

NFSv4.1 adds back in those callbacks, but we only got around to implementing that recently.  If you could rerun your tests with a 4.9 or later kernel (on both client and server), it'd be interesting to see the results.

(There's a subtle difference between the callbacks in the v3 and v4.1 cases--in the v3 case the callback itself actually granted the lock, in the v4.1 case it's just a hint to the client that this would be a good time for it to retry.  In theory 4.1 should get close to the same performance that way while avoiding some race conditions that were possible in the v3 case.)

--b.

> 
> We can reproduce this in multiple Linux versions (At least SuSE 11, SuSE 12, Ubuntu 14.04, Red Hat 7.x), and multiple NFS servers (Linux, Solaris, NetApp) and the issue only occurs on NFSv4 mounts. Mounting the exact same filesystem via NFSv3 eliminates the issue. We're reasonably certain that this is not a client configuration issue as additional customers are coming out of the woodwork reporting the problem. We're also reasonably certain that this is not a server issue since it's happening across multiple server platforms. 
> 
> To reproduce this outside of our application, a coworker wrote a simple lock test program (attached). When one instance of this program is run on an affected host, the lock times are < 1000us. If you then start a second instance of the application, the lock wait times have reached as long as 3 MINUTES. Unlocking doesn't take anywhere near as long, where the maximum observed unlock time being about 23 ms. 
> 
> Process we used to prove this:
> 1) Compiled the attached source.
> 2) Mounted a remote filesystem via NFSv4 (example: /mnt/nfsv4)
> 3) Created a temp file with 777 permissions. (/mnt/nfsv4/foo)
> 4) Ran one instance of the tool, redirecting the output to /tmp:
> ./lock1 /mnt/nfsv4/foo >> /tmp/zz1 &
> 5) Checked lock times after 20 seconds: 
> sort -rn -k3 < /tmp/zz1 | more
> 6) Started a second instance of the tool
> ./lock1 /mnt/nfsv4/foo >> /tmp/zz2 &
> 7) Check the lock times again, using both files:
> sort -rn -k3 < /tmp/zz1 | more
> sort -rn -k3 < /tmp/zz2 | more
> 
> What we saw was lock calls moving from the < 1000 us range to (as my coworker put it) "integral numbers of seconds." Not every lock stalls for integral numbers of seconds, but enough of them do to stall our application. Even the small percentage of > 1 second lock/unlock calls causes problems as we do a lot of file locking. 
> 
> Any/all diagnostic assistance would be greatly appreciated.
> 
> 
> ::DISCLAIMER::
> ----------------------------------------------------------------------
> ----------------------------------------------------------------------
> --------
> 
> The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
> E-mail transmission is not guaranteed to be secure or error-free as 
> information could be intercepted, corrupted, lost, destroyed, arrive 
> late or incomplete, or may contain viruses in transmission. The e mail and its contents (with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
> Views or opinions, if any, presented in this email are solely those of 
> the author and may not necessarily reflect the views or opinions of 
> HCL or its affiliates. Any form of reproduction, dissemination, 
> copying, disclosure, modification, distribution and / or publication of this message without the prior written consent of authorized representative of HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
> Before opening any email and/or attachments, please check them for viruses and other defects.
> 
> ----------------------------------------------------------------------
> ----------------------------------------------------------------------
> --------

> #include <stdio.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/time.h>
> 
> #define MAXBUF 4096
> 
> main(argc, argv)
> int argc;
> char *argv[];
> {
> 
>     int i;
>     int fd;
>     pid_t pid;
>     int sleep_time;
>     int time_taken=0;
>     char buffer[MAXBUF];
>     struct timeval t1, t2;
> 
>     setbuf(stdout, NULL);
>     /* Populate new block */
>     for(i=0; i<MAXBUF; i++)
>        buffer[i]='c';
> 
>     /* a single arg  - the  filename*/
>     if (argc != 2){
>        fprintf(stderr, "usage: %s <file>\n", argv[0]);
>        _exit(2);
>     }
> 
>     /* Check arg is a file can open r/w */
>     if ((fd=open(argv[1], O_RDWR, 0777)) <0) {
>        fprintf(stderr, "could not create/open %s \n", argv[1]);
>        _exit(1);
>     }
> 
> 
>     /* Loop forever */
>     while(1){
>            /* Reset file pointer to start of file */
>            if (lseek(fd, 0, SEEK_SET) < 0) {
>               fprintf(stderr, "could not seek to beginning of %s\n", argv[1]);
>               _exit(1);
>            }
> 
>            /* Lock entire file for exclusive access  and time how long it takes to get lock*/
>            gettimeofday(&t1, NULL);
>            if (lockf(fd, F_LOCK, 0) < 0) {
>               fprintf(stderr, "could not lock whole file %s\n", argv[1]);
>               _exit(1);
>            }
>            gettimeofday(&t2, NULL);
>            time_taken=(t2.tv_sec - t1.tv_sec)*1000000 + (t2.tv_usec - t1.tv_usec);
>               printf("lockf() took  %d us\n", time_taken);
> 
>            /* Unlock file  and time how long that takes*/
>            gettimeofday(&t1, NULL);
>            if (lockf(fd, F_ULOCK, 0) < 0) {
>               fprintf(stderr, "could not unlock file %s\n", argv[1]);
>               _exit(1);
>            }
>            gettimeofday(&t2, NULL);
>            time_taken=(t2.tv_sec - t1.tv_sec)*1000000 + (t2.tv_usec - t1.tv_usec);
>               printf("unlock() took %d us\n", time_taken);
> 
>   }
> _exit(0);
> }

