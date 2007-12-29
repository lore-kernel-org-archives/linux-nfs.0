From: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW related
Date: Sat, 29 Dec 2007 03:11:08 -0800 (PST)
Message-ID: <86290.88050.qm@web32604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	spam trap <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32604.mail.mud.yahoo.com ([68.142.207.231]:36781 "HELO
	web32604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751931AbXL2LLJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Dec 2007 06:11:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----
> From: Chris Snook <csnook@redhat.com>
> To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org
> Sent: Friday, December 28, 2007 7:45:13 PM
> Subject: Re: Strange NFS write performance Linux->Solaris-10/VXFS, maybe VW related
> 
> Martin Knoblauch wrote:
> > Hi,
> > 
> > currently I am tracking down an "interesting" effect when writing

> 3) It sounds like the bottleneck is the vxfs filesystem.  It
> only *appears* on  the client side because writes up until dirty_ratio
> get buffered on the client. 
>   If you can confirm that the server is actually writing stuff to
> disk slower  when the client is in writeback mode, then it's possible
> the Linux NFSclient is  doing something inefficient in writeback mode.
> 

so, is the output of "iostat -d -l1 d111" during two runs. The first run is with 750 MB, the second with 850MB.

// 750MB
$ iostat -d -l 1 md111 2
   md111
kps tps serv
 22   0   14
  0   0    0
  0   0   13
29347 468   12
37040 593   17
30938 492   25
30421 491   25
41626 676   16
42913 703   14
39890 647   15
9009 141    7
8963 141    7
5143  81    7
34814 547   10
49323 775   12
28624 451    6
 22   1    6
#### finish
  0   0    0
  0   0    0

 Here it seems that the disk is writing for 26-28 seconds with avg. 29 MB/sec. Fine.

// 850MB
$ iostat -d -l 1 md111 2
   md111
kps tps serv
  0   0    0
11275 180   10
39874 635   14
37403 587   17
24341 392   30
25989 423   26
22464 375   30
21922 361   32
27924 450   26
21507 342   21
9217 153   15
9260 150   15
9544 155   15
9298 150   14
10118 162   11
15505 250   12
27513 448   14
26698 436   15
26144 431   15
25201 412   14
#### 38 seconds in run
  0   0    0
  0   0    0
579  17   12
  0   0    0
  0   0    0
  0   0    0
  0   0    0
518   9   16
485   8    6
  9   1    7
514   9    7
  0   0    0
  0   0    0
541   9    8
532  10    6
  0   0    0
  0   0    0
650  12    7
  0   0    0
242   8    9
1023  18    5
304   5    6
418   8    7
283   5    5
303   5    8
527  10    6
  0   0    0
  0   0    0
  0   0    0
  5   1   13
  0   0    0
  0   0    0
  0   0    0
  0   0    0
  0   0    0
  0   0   11
  0   0    0
  0   0    0
  0   0    0
  1   0   15
  0   0    0
 96   2   15
138   3   10
11057 175    6
17549 280    6
351   8    5
  0   0    0
##### 218 seconds in run, finish.

 So, for the first 38 seconds everything looks similar to the 750 MB case. For the next about 180 seconds most time nothing happens. Averaging 4.1 MB/sec.

Maybe it is time to capture the traffic. What are the best tcpdump parameters for NFS? I always forget :-(

Cheers
Martin



