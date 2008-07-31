From: Michael Shuey <shuey@purdue.edu>
Subject: Re: high latency NFS
Date: Wed, 30 Jul 2008 22:35:49 -0400
Message-ID: <200807302235.50068.shuey@purdue.edu>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au>
Reply-To: shuey@purdue.edu
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: Shehjar Tikoo <shehjart@cse.unsw.edu.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758788AbYGaCgR@vger.kernel.org>
In-Reply-To: <4890DFC7.3020309@cse.unsw.edu.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for all the tips I've received this evening.  However, I figured out 
the problem late last night. :-)

I was only using the default 8 nfsd threads on the server.  When I raised 
this to 256, the read bandwidth went from about 6 MB/sec to about 95 
MB/sec, at 100ms of netem-induced latency.  Not too shabby.  I can get 
about 993 Mbps on the gigE link between client and server, or 124 MB/sec 
max, so this is about 76% of wire speed.  Network connections pass through 
three switches, at least one of which acts as a router, so I'm feeling 
pretty good about things so far.

FYI, the server is using an ext3 file system, on top of a 10 GB /dev/ram0 
ramdisk (exported async, mounted async).  Oddly enough, /dev/ram0 seems a 
bit slower than tmpfs and a loopback-mounted file - go figure.

To avoid confusing this with cache effects, I'm using iozone on an 8GB file 
from a client with only 4GB of memory.  Like I said, I'm mainly interested 
in large file performance. :-)

-- 
Mike Shuey
Purdue University/ITaP


On Wednesday 30 July 2008, Shehjar Tikoo wrote:
> J. Bruce Fields wrote:
> > You might get more responses from the linux-nfs list (cc'd).
> >
> > --b.
> >
> > On Thu, Jul 24, 2008 at 01:11:31PM -0400, Michael Shuey wrote:
> >> I'm currently toying with Linux's NFS, to see just how fast it
> >> can go in a high-latency environment.  Right now, I'm simulating
> >>  a 100ms delay between client and server with netem (just 100ms
> >> on the outbound packets from the client, rather than 50ms each
> >> way). Oddly enough, I'm running into performance problems. :-)
> >>
> >> According to iozone, my server can sustain about 90/85 MB/s
> >> (reads/writes) without any latency added.  After a pile of
> >> tweaks, and injecting 100ms of netem latency, I'm getting 6/40
> >> MB/s (reads/writes).  I'd really like to know why writes are now
> >>  so much faster than reads, and what sort of things might boost
> >> the read throughput.  Any suggestions?
>
> Is the server sync or async mounted? I've seen such performance
> inversion between read and write when the mount mode is async.
>
> What is the number of nfsd threads at the server?
>
> Which file system are you using at the server?
>
> >> 1 The read throughput seems to be proportional to the latency -
> >> adding only 10ms of delay gives 61 MB/s reads, in limited testing
> >>  (need to look at it further).  While that's to be expected, to
> >> some extent, I'm hoping there's some form of readahead that can
> >> help me out here (assume big sequential reads).
> >>
> >> iozone is reading/writing a file twice the size of memory on the
> >>  client with a 32k block size.  I've tried raising this as high
> >> as 16 MB, but I still see around 6 MB/sec reads.
>
> In iozone, are you running the read and write test during the same run
> of iozone? Iozone runs read tests, after writes so that the file for
> the read test exists on the server. You should try running write and
> read tests in separate runs to prevent client side caching issues from
> influencing raw server read(and read-ahead) performance. You can use
> the -w option in iozone to prevent iozone from calling unlink on the
> file after the write test has finished, so you can use the same file
> in a separate read test run.
>
> >> I'm using a 2.6.9 derivative (yes, I'm a RHEL4 fan).  Testing
> >> with a stock 2.6, client and server, is the next order of
> >> business.
>
> You can try building the kernel with oprofile support and use it to
> measure where the client CPU is spending its time. It is possible that
> client-side locking or other algorithm issues are resulting in such
> low read throughput. Note, when you start oprofile profiling, use a
> CPU_CYCLES count of 5000. I've observed more accurate results with
> this sample size for NFS performance.
>
> >> NFS mount is tcp, version 3.  rsize/wsize are 32k.  Both client
> >> and server have had tcp_rmem, tcp_wmem, wmem_max, rmem_max,
> >> wmem_default, and rmem_default tuned - tuning values are 12500000
> >>  for defaults (and minimum window sizes), 25000000 for the
> >> maximums.  Inefficient, yes, but I'm not concerned with memory
> >> efficiency at the moment.
> >>
> >> Both client and server kernels have been modified to provide
> >> larger-than-normal RPC slot tables.  I allow a max of 1024, but
> >> I've found that actually enabling more than 490 entries in /proc
> >>  causes mount to complain it can't allocate memory and die.  That
> >>  was somewhat suprising, given I had 122 GB of free memory at the
> >>  time...
> >>
> >> I've also applied a couple patches to allow the NFS readahead to
> >>  be a tunable number of RPC slots.  Currently, I set this to 489
> >>  on client and server (so it's one less than the max number of
> >> RPC slots).  Bandwidth delay product math says 380ish slots
> >> should be enough to keep a gigabit line full, so I suspect
> >> something else is preventing me from seeing the readahead I
> >> expect.
> >>
> >> FYI, client and server are connected via gigabit ethernet.
> >> There's a couple routers in the way, but they talk at 10gigE and
> >>  can route wire speed. Traffic is IPv4, path MTU size is 9000
> >> bytes.
>
> The following are not completely relevant here but just to get some
> more info:
> What is the raw TCP throughput that you get between the server and
> client machine on this network?
>
> You could run the tests with bare minimum number of network
> elements between the server and the client to see whats the best
> network performance for NFS you can extract from this server and
> client machine.
>
> >> Is there anything I'm missing?
> >>
> >> -- Mike Shuey Purdue University/ITaP
