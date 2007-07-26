From: "Wim Colgate" <Wim.Colgate@xensource.com>
Subject: Re: question on the inner workings of NFS soft mount
Date: Thu, 26 Jul 2007 15:39:12 -0700
Message-ID: <A9AD3C3BCF83FD4182B7D4D99E37FAD82FA070@exchrdm.ad.xensource.com>
References: <1185489541.6585.267.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEC0o-0006sO-25
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 15:40:50 -0700
Received: from webmailrdm.xensource.com ([66.228.214.202])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEC0r-0005pW-LP
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 15:40:54 -0700
In-Reply-To: <1185489541.6585.267.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Sure thing, I'll try UDP. One thing I forgot to add is that if the cable
is unplugged, the times are nicely 300ms timeouts -- which must eschew
any TCP backoff if the host is unreachable.

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Sent: Thursday, July 26, 2007 3:39 PM
To: Wim Colgate
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] question on the inner workings of NFS soft mount

You are probably seeing a side effect of the TCP re-connection backoff
algorithm. I'll bet you that the numbers change if you try UDP.

Trond

On Thu, 2007-07-26 at 15:29 -0700, Wim Colgate wrote:
> I was wondering if anyone could help me interpret the results of the
> following experiment with regards to NFS softmount.
> 
>  
> 
> First a very brief description of my setup and test program:
> 
>  
> 
> I have a simple program that does a small, 512 byte, write to a file,
> and print the success/failure of the IO plus the time the write took
> to return, sleep one second, then loop back and write another - repeat
> until ^C. The file it is writing to is on an NFS filer. During its
> execution, I will disable the NFS service on the filer. The printfs of
> success/failure are below.
> 
>  
> 
> The mount is SOFT: 
> 
>  
> 
> 172.24.0.90:/vhd1 on /mnt/snp1 type nfs
> (rw,soft,timeo=1,retrans=1,addr=172.24.0.90)
> 
>  
> 
> When I run one instance of the program here is the output:
> 
>  
> 
> # ./netwrite /mnt/snp1/foo2
> 
> write block 0 (succeeded): 0.006674 secs
> 
> write block 1 (succeeded): 0.001639 secs
> 
> write block 2 (succeeded): 0.001793 secs
> 
> write block 3 (succeeded): 0.001784 secs
> 
> write block 4 (succeeded): 0.004258 secs
> 
> write block 5 (succeeded): 0.002426 secs
> 
> write block 6 (succeeded): 0.001494 secs
> 
> write block 7 (succeeded): 0.001477 secs
> 
> write block 8 (succeeded): 0.001271 secs
> 
> write block 9 (failed): 3.00014 secs
> 
> write block 10 (failed): 3.00015 secs
> 
> write block 11 (failed): 6.00012 secs
> 
> write block 12 (failed): 12.0001 secs
> 
> write block 13 (failed): 24 secs
> 
> write block 14 (failed): 47.9999 secs
> 
> write block 15 (failed): 59.9996 secs
> 
> write block 16 (failed): 35 secs
> 
> write block 17 (failed): 59.9997 secs
> 
> write block 18 (failed): 59.9997 secs
> 
> write block 19 (failed): 59.9997 secs
> 
> write block 20 (failed): 9.00012 secs
> 
>  
> 
>  
> 
> I'm curious as to why the write failure times are all over the place.
> Note the timeo and retrans are both set to 1. If I run two
> simultaneous instances (to different files on the same filer), the
> times are also all over the place - and go as high as two minutes
> (curiously twice the max as one...).
> 
>  
> 
> I'm using the following version of linux:
> 
>  
> 
> Linux wims 2.6.18-8.1.8.el5.xs4.0.0b2.102.154xen #1 SMP Tue Jul 24
> 16:57:36 EDT 2007 i686 i686 i386 GNU/Linux
> 
>  
> 
> The program is pretty simple:
> 
>  
> 
> #define O_DIRECT        040000
> 
>  
> 
> #include <stdio.h>
> 
> #include <sys/types.h>
> 
> #include <sys/stat.h>
> 
> #include <fcntl.h>
> 
> #include <unistd.h>
> 
> #include <sys/select.h>
> 
> #include <errno.h>
> 
> #include <string.h>
> 
> #include <stdlib.h>
> 
>  
> 
> #include <sys/time.h>
> 
>  
> 
> #define ALIGN 512
> 
> #define SIZE 512
> 
> #define SEC_WAIT 1
> 
>  
> 
> main(int argc, char *argv[])
> 
> {
> 
>     int fd;
> 
>  
> 
>     int data=0;
> 
>     char *bufptr = 0;
> 
>     int result;
> 
>     struct timeval tim;
> 
>     struct timeval start;
> 
>     struct timeval end;
> 
>  
> 
>     if (argc != 2) {
> 
>         printf("usage: %s <filename>\n", argv[0]);
> 
>         goto done;
> 
>     }
> 
>  
> 
>     posix_memalign((void **)&bufptr, ALIGN, SIZE);
> 
>     if (!bufptr) {
> 
>         printf("failed to allocate %d bytes", SIZE);
> 
>         goto done;
> 
>     }
> 
>  
> 
>     fd = open(argv[1], O_RDWR | O_CREAT | O_DIRECT, 0777);
> 
>  
> 
>     if (!fd) {
> 
>         printf("failed to open %s for write, errno=%d\n", argv[1],
> errno);
> 
>         goto done;
> 
>     }
> 
>  
> 
>     while (1) {
> 
>         ftime(&start);
> 
>         tim.tv_sec = SEC_WAIT;
> 
>         tim.tv_usec = 0;
> 
>         memset(bufptr, data, SIZE);
> 
>         gettimeofday(&start, 0);
> 
>         result = write(fd, bufptr, SIZE);
> 
>         data = (data+1) & 255;
> 
>         gettimeofday(&end, 0);
> 
>         printf("write block %d (%s): %g secs\n",
> 
>                                      data-1,
> 
>                                      result < 0 ? "failed" :
> "succeeded",
> 
>                                      ((end.tv_sec*1000000 +
> end.tv_usec) -
> 
>                                       (start.tv_sec*1000000 +
> start.tv_usec))
> 
>                                       /1000000.0);
> 
>         select(0, 0, 0, 0, &tim);
> 
>     }
> 
>  
> 
> done:
> 
>     return 0;
> 
> }
> 
>  
> 
> Thanks,
> 
>  
> 
> Wim
> 
> 
>
------------------------------------------------------------------------
-
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a
browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________ NFS maillist -
NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
