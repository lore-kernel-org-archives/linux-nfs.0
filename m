From: Christian Reis <kiko@async.com.br>
Subject: Re: General network slowness on SIS 530 with eepro100
Date: Thu, 15 Aug 2002 20:40:04 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3740.21041575379$1029455118@news.gmane.org>
References: <20020813212923.L2219@blackjesus.async.com.br> <shs1y92p7ho.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eepro100@scyld.com, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pina.terra.com.br ([200.176.3.17])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fUDt-0004Lj-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 16:40:14 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs1y92p7ho.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, Aug 14, 2002 at 03:13:55AM +0200
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, Aug 14, 2002 at 03:13:55AM +0200, Trond Myklebust wrote:
> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > Helle there,
> 
>      > I've been, for the past days, setting up a fairly big diskless
>      > network based on Linux. I've chosen to use 2.4.19 as the kernel
>      > because there were some hardware requirements, and for most of
>      > the newer boxes, it runs fine. However, for three of the older
>      > boxes, we have had some pretty odd performance and stability
>      > issues. This message is about the latest one, which is an ASUS
>      > P5S-B (has the infamous SIS 530 chipset) on an intel eepro100
>      > card. Details:
> 
> Is all this NFS over UDP? If so, numbers should not really have
> changed in 2.4.19 ( - yes my patchset changes things, but stock 2.4.19
> should not be too different w.r.t 2.4.18)

Trond, I've been looking at this a bit more. I've tried 2.4.18 and
2.2.21 and nothing changes - it always looks bad. If I look at top
output for

    time dd if=/dev/zero of=TESTFILE count=3000 bs=100k

rpciod is around 60% of CPU and there is 0% idle. A typical vmstat line
is:

  procs                      memory    swap          io     system cpu
r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs us  sy  id 
1  0  0      0  16228      4 197316   0   0     0     0 1426   603 14  86   0

Now, I contrast this to the other box (same CPU speed, other mobo):

  procs                      memory    swap          io     system cpu
r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs us  sy  id 
0  1  0      0 196216      0  53656   0   0     0     0  103     9   0 0 100

I see rpciod running, but very rarely. So any idea why rpciod would be
running and burning up CPU a lot in the first case, but not in the
second? Maybe I need a kernel profiler to go after the actual problem?

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
