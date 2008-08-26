From: Grant Coady <grant_lkml@dodo.com.au>
Subject: Re: NFS regression? Odd delays and lockups accessing
	an NFS export.
Date: Tue, 26 Aug 2008 10:29:17 +1000
Message-ID: <kgh6b498u1t11gur76aefbs878grh5gal7@4ax.com>
References: <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	<1219428489.6919.21.camel@localhost>
	<1219428818.27921.43.camel@localhost.localdomain>
	<56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	<1219435207.27921.51.camel@localhost.localdomain>
	<1219440202.9097.14.camel@localhost>
	<1219441041.27921.57.camel@localhost.localdomain>
	<1219442213.9097.25.camel@localhost>
	<4156b4tgrrsflla1svmu4jl6j5sme4a715@4ax.com>
	<1219702272.7665.56.camel@localhost>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, Grant Coady <gcoady.lk@gmail.com>,
	e1000-devel@lists.sourceforge.net, neilb@suse.de,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@gmail.com>, bfields@fieldses.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ian Campbell <ijc@hellion.org.uk>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1219702272.7665.56.camel@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 25 Aug 2008 18:11:12 -0400, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

>On Tue, 2008-08-26 at 06:23 +1000, Grant Coady wrote:
>> On Fri, 22 Aug 2008 14:56:53 -0700, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>> 
>> >On Fri, 2008-08-22 at 22:37 +0100, Ian Campbell wrote:
>> >> I can ssh to the server fine. The same server also serves my NFS home
>> >> directory to the box I'm writing this from and I've not seen any trouble
>> >> with this box at all, it's a 2.6.18-xen box.
>> >
>> >OK... Are you able to reproduce the problem reliably?
>> >
>> >If so, can you provide me with a binary tcpdump or wireshark dump? If
>> >using tcpdump, then please use something like
>> >
>> >   tcpdump -w /tmp/dump.out -s 90000 host myserver.foo.bar and port 2049
>>                              ^^^^^^^^-->  typo?
>
>No. The intention was to record _all_ the info in the packet for
>analysis, not just random header info.

Hi Trond,

My tcpdump seems to have a 16 bit snaplen counter:

~# tcpdump -w /tmp/dump.out -s 65535 host deltree and port 2049
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
^C0 packets captured
4 packets received by filter
0 packets dropped by kernel

~# tcpdump -w /tmp/dump.out -s 65536 host deltree and port 2049
tcpdump: invalid snaplen 65536

~# tcpdump --version
tcpdump version 3.9.8
libpcap version 0.9.8


So I'm now using:
~# tcpdump -w /tmp/dump.out -s 65535 -C 10 -W 100 host deltree and port 2049
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes

to get a 1GB round-robin trace buffer, I can stop the trace when problem 
noticed, as it is so long between delay/stall happenings.  Then I'll try 
to trigger the thing.

Is this the correct style of trace you are expecting?

~$ /usr/sbin/tcpdump -r /tmp/dump.out00
reading from file /tmp/dump.out00, link-type EN10MB (Ethernet)
10:13:49.719781 IP pooh64.mire.mine.nu.2156510591 > deltree.mire.mine.nu.nfs: 116 access fh 0,1/218104576 001f
10:13:49.720215 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.2156510591: reply ok 124 access c 001f
10:13:49.720225 IP pooh64.mire.mine.nu.984 > deltree.mire.mine.nu.nfsd: . ack 1649405551 win 5840
10:13:49.720288 IP pooh64.mire.mine.nu.2173287807 > deltree.mire.mine.nu.nfs: 136 readdirplus fh 0,1/218104576 512 bytes @ 0
10:13:49.742450 IP deltree.mire.mine.nu.nfs > pooh64.mire.mine.nu.2173287807: reply ok 1460 readdirplus


Is there some test suite I can use?  Compiling kernels over NFS worked 
fine yesterday, apart from the fastest box' make complaining about clock 
skew.  The kernel booted though, so that was okay.  

Guess it's back to the interactive editing over NFS and see if the thing 
manifest the delay/stalls again, I'm on the .27-rc4-git4 kernel as soon 
as it compiles for the client, NFS server is 2.6.24.7 at the moment.

Grant.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
