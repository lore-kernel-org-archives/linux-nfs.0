From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] direct-IO API change
Date: Sat, 05 Oct 2002 12:34:04 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3D9F3EAC.590738BA@digeo.com>
References: <Pine.LNX.4.44.0210041621170.2526-100000@home.transmeta.com
	 > <5.1.0.14.2.20021005194507.031018c0@mira-sjcm-3.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Chuck Lever <cel@citi.umich.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Lincoln Dale <ltd@cisco.com>
List-ID: <nfs.lists.sourceforge.net>

Lincoln Dale wrote:
> 
> At 04:23 PM 4/10/2002 -0700, Linus Torvalds wrote:
> >Especially since I thought that O_DIRECT on the regular file (or block
> >device) performed about as well as raw does anyway these days? Or is that
> >just one of my LSD-induced flashbacks?
> 
> from my multiple 64/66 PCI bus + multiple 2gbit/s FC HBA tests, yes,
> they're around the same.
> (now up to 390mbyte/sec throughput on latest & greatest x86 hardware i
> have; front-side-bus no longer the limiting factor, but dual 64/66 PCI).
> 
> of course, purely synthetic tests designed to stress Fibre Channel
> switching infrastructure, not real-world disk i/o..
> 

direct-io has lost its challenge ;)

I'd love to see the result of some pagecache testing on that
setup if you have time.

Nothing fancy - just:

for i in $(each ext2 mountpoint)
do
	dd if=/dev/zero of=$i/foo bs-1M count=4000 &
done
vmstat 1

and

for i in $(each ext2 mountpoint)
do
	cat $i/foo > /dev/null &
done
vmstat 1

Linus's current BK tree has a few warmups which will help the
writeout phase a little.
