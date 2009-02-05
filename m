Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:44363 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbZBEPIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 10:08:39 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n15F8YGu029014
	for <linux-nfs@vger.kernel.org>; Thu, 5 Feb 2009 20:38:34 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n15F6DMC4399118
	for <linux-nfs@vger.kernel.org>; Thu, 5 Feb 2009 20:36:13 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n15F8Y71024205
	for <linux-nfs@vger.kernel.org>; Fri, 6 Feb 2009 02:08:34 +1100
In-Reply-To: <20090204231958.GB20917@fieldses.org>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain> <20090204231958.GB20917@fieldses.org>
Subject: Re: [RFC PATCH 0/1] nfsd: Improve NFS server performance
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Message-ID: <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com>
From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 5 Feb 2009 20:38:19 +0530
Content-type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

Thanks for your comments (also please refer to REV2 of patch as that is
much simpler).

> >
> > Patch summary:
> > --------------
> > Change the readahead caching on the server to a file handle caching
model.
> > Since file handles are unique, this patch removes all dependencies on
the
> > kernel readahead parameters/implementation and instead caches files
based
> > on file handles. This change allows the server to not have to
open/close
> > a file multiple times when the client reads it, and results in faster
lookup
> > times.
>
> I think of open and lookup as fairly fast, so I'm surprised this makes a
> great difference; do you have profile results or something to confirm
> that this is in fact what made the difference?

Beyond saving the open/lookup times, the cache is updated only once. Hence
no
lock plus update is required for subsequent reads - the code does a single
lock
on every read operation instead of two. The time to get the cache is
approximately the same for old vs new code; but in the new code we get
file/dentry and svc_exp.

I used to have counters in nfsd_open - something like dbg_num_opens,
dbg_open_jiffies, dgb_close_jiffies, dbg_read_jiffies, dgb_cache_jiffies,
etc.
I can reintroduce those debugs and get a run and see how those numbers
looks
like, is that what you are looking for?

> > Also, readahead is automatically taken care of since the file is not
> > closed while it is getting read (quickly) by the client.
> >
> >
> > Read algo change:
> > ------------------
> > The new nfsd_read() is changed to:
> >    if file {
> >       Old code
> >    } else {
> >       Check if this FH is cached
> >       if fh && fh has cached file pointer:
> >          Get file pointer
> >          Update fields in fhp from cache
> >          call fh_verify
> >       else:
> >          Nothing in the cache, call nfsd_open as usual
> >
> >       nfsd_vfs_read
> >
> >       if fh {
> >          If this is a new fh entry:
> >             Save cached values
> >          Drop our reference to fh
> >       } else
> >          Close file
> >    }
>
> When do items get removed from this cache?

At the first open, the item is kept at the end of a global list (which is
manipulated by the new daemon). After some jiffies are over, the daemon
goes through the list till it comes to the first entry that has not
expired; and frees up all the earlier entries. If the file is being used,
it is not freed. If file is used after free, a new entry is added to the
end of the list. So very minimal list manipulation is required - no sorting
and moving entries in the list.

Please let me know if you would like me to write up a small text about how
this patch works.

> > Performance:
> > -------------
> > This patch was tested with clients running 1, 4, 8, 16 --- 256 test
processes,
> > each doing reads of different files. Each test includes different I/O
sizes.
> > Many individual tests (16% of test cases) got throughput improvement in
the
> > 9 to 15% range. The full results are provided at the end of this post.
>
> Could you provide details sufficient to reproduce this test if
> necessary?  (At least: what was the test code, how many clients were
> used, what was the client and server hardware, and what filesystem was
> the server exporting?)

Sure - I will send the test code in a day (don't have access to the system
right
now, sorry. But this is a script that runs a C program that forks and then
reads
a file till it is killed and it prints the amount of data read and the
amount of
time it ran).

The other details are:
      #Clients: 1
      Hardware Configuration (both systems):
            Two Dual-Core AMD Opteron (4 cpus) at 3GH.
            1GB memory
            10gbps private network
      Filesystem: ext3 (one filesystem)

Thanks,

- KK

> > Please review. Any comments or improvement ideas are greatly
appreciated.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >
> >       (#Test Processes on Client == #NFSD's on Server)
> > --------------------------------------------------------------
> > #Test Processes      Org BW KB/s   New BW KB/s   %
> > --------------------------------------------------------------
>
> What's the second column?
>
> > 4   256      48151.09   50328.70   4.52
> > 4   4096      47700.05   49760.34   4.31
> > 4   8192      47553.34   48509.00   2.00
> > 4   16384      48764.87   51208.54   5.01
> > 4   32768      49306.11   50141.59   1.69
> > 4   65536      48681.46   49491.32   1.66
> > 4   131072      48378.02   49971.95   3.29
> >
> > 8   256      38906.95   42444.95   9.09
> > 8   4096      38141.46   42154.24   10.52
> > 8   8192      37058.55   41241.78   11.28
> > 8   16384      37446.56   40573.70   8.35
> > 8   32768      36655.91   42159.85   15.01
> > 8   65536      38776.11   40619.20   4.75
> > 8   131072      38187.85   41119.04   7.67
> >
> > 16   256      36274.49   36143.00   -0.36
> > 16   4096      34320.56   37664.35   9.74
> > 16   8192      35489.65   34555.43   -2.63
> > 16   16384      35647.32   36289.72   1.80
> > 16   32768      37037.31   36874.33   -0.44
> > 16   65536      36388.14   36991.56   1.65
> > 16   131072      35729.34   37588.85   5.20
> >
> > 32   256      30838.89   32811.47   6.39
> > 32   4096      31291.93   33439.83   6.86
> > 32   8192      29885.57   33337.10   11.54
> > 32   16384      30020.23   31795.97   5.91
> > 32   32768      32805.03   33860.68   3.21
> > 32   65536      31275.12   32997.34   5.50
> > 32   131072      33391.85   34209.86   2.44
> >
> > 64   256      26729.46   28077.13   5.04
> > 64   4096      25705.01   27339.37   6.35
> > 64   8192      27757.06   27488.04   -0.96
> > 64   16384      22927.44   23938.79   4.41
> > 64   32768      26956.16   27848.52   3.31
> > 64   65536      27419.59   29228.76   6.59
> > 64   131072      27623.29   27651.99   .10
> >
> > 128   256      22463.63   22437.45   -.11
> > 128   4096      22039.69   22554.03   2.33
> > 128   8192      22218.42   24010.64   8.06
> > 128   16384      15295.59   16745.28   9.47
> > 128   32768      23319.54   23450.46   0.56
> > 128   65536      22942.03   24169.26   5.34
> > 128   131072      23845.27   23894.14   0.20
> >
> > 256   256      15659.17   16266.38   3.87
> > 256   4096      15614.72   16362.25   4.78
> > 256   8192      16950.24   17092.50   0.83
> > 256   16384      9253.25      10274.28   11.03
> > 256   32768      17872.89   17792.93   -.44
> > 256   65536      18459.78   18641.68   0.98
> > 256   131072      19408.01   20538.80   5.82
> > --------------------------------------------------------------
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

