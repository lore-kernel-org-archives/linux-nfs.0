Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60301 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682Ab2HQQBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 12:01:01 -0400
Date: Fri, 17 Aug 2012 12:00:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
Message-ID: <20120817160057.GE11172@fieldses.org>
References: <20120530132518.GA13794@fieldses.org>
 <4FC713ED.5040807@msgid.tls.msk.ru>
 <1338469169.2420.7.camel@lade.trondhjem.org>
 <4FC77128.9090206@msgid.tls.msk.ru>
 <1338471975.7732.5.camel@lade.trondhjem.org>
 <4FC77755.5060606@msgid.tls.msk.ru>
 <4FFC2573.8040804@msgid.tls.msk.ru>
 <20120712125303.GC16822@fieldses.org>
 <502DA4E8.9050800@msgid.tls.msk.ru>
 <20120817145616.GC11172@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120817145616.GC11172@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 17, 2012 at 10:56:16AM -0400, J. Bruce Fields wrote:
> On Fri, Aug 17, 2012 at 05:56:56AM +0400, Michael Tokarev wrote:
> > On 12.07.2012 16:53, J. Bruce Fields wrote:
> > > On Tue, Jul 10, 2012 at 04:52:03PM +0400, Michael Tokarev wrote:
> > >> I tried to debug this again, maybe to reproduce in a virtual machine,
> > >> and found out that it is only 32bit server code shows this issue:
> > >> after updating the kernel on the server to 64bit (the same version)
> > >> I can't reproduce this issue anymore.  Rebooting back to 32bit,
> > >> and voila, it is here again.
> > >>
> > >> Something apparenlty isn't right on 32bits... ;)
> > >>
> > >> (And yes, the prob is still present and is very annoying :)
> > > 
> > > OK, that's very useful, thanks.  So probably a bug got introduced in the
> > > 32-bit case between 2.6.32 and 3.0.
> > > 
> > > My personal upstream testing is normally all x86_64 only.  I'll kick off
> > > a 32-bit install and see if I can reproduce this quickly.
> > 
> > Actually it has nothing to do with 32 vs 64 bits as I
> > initially thought.  It happens on 64bits too, but takes
> > more time (or data to transfer) to trigger.
> 
> That makes it sound like some kind of leak: you're hitting this case
> eventually either way, but it takes longer in the case where you have
> more (low) memory.
> 
> I wish I was more familiar with the tcp code.... What number exactly is
> being compared against those limits, and how could we watch it from
> userspace?

Uh, if I grepped my way through this right: it looks like it's the
"memory" column of the "TCP" row of /proc/net/protocols; might be
interesting to see how that's changing over time.

> 
> --b.
> 
> > 
> > 
> > > Let me know if you're able to narrow this down any more.
> > 
> > I bisected this issue to the following commit:
> > 
> > commit f03d78db65085609938fdb686238867e65003181
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Thu Jul 7 00:27:05 2011 -0700
> > 
> >     net: refine {udp|tcp|sctp}_mem limits
> > 
> >     Current tcp/udp/sctp global memory limits are not taking into account
> >     hugepages allocations, and allow 50% of ram to be used by buffers of a
> >     single protocol [ not counting space used by sockets / inodes ...]
> > 
> >     Lets use nr_free_buffer_pages() and allow a default of 1/8 of kernel ram
> >     per protocol, and a minimum of 128 pages.
> >     Heavy duty machines sysadmins probably need to tweak limits anyway.
> > 
> > 
> > Reverting this commit on top of 3.0 (or any later 3.x kernel) fixes
> > the behavour here.
> > 
> > This machine has 4Gb of memory.  On 3.0, with this patch applied
> > (as it is part of 3.0), tcp_mem is like this:
> > 
> >   21228     28306   42456
> > 
> > with this patch reverted, tcp_mem shows:
> > 
> >   81216     108288  162432
> > 
> > and with these values, it works fine.
> > 
> > So it looks like something else goes wrong there,
> > which lead to all nfsds fighting with each other
> > for something and eating 100% of available CPU
> > instead of servicing clients.
> > 
> > For added fun, when setting tcp_mem to the "good" value
> > from "bad" value (after booting into kernel with that
> > patch applied), the problem is _not_ fixed.
> > 
> > Any further hints?
> > 
> > Thanks,
> > 
> > /mjt
> > 
> > >> On 31.05.2012 17:51, Michael Tokarev wrote:
> > >>> On 31.05.2012 17:46, Myklebust, Trond wrote:
> > >>>> On Thu, 2012-05-31 at 17:24 +0400, Michael Tokarev wrote:
> > >>> []
> > >>>>> I started tcpdump:
> > >>>>>
> > >>>>>  tcpdump -npvi br0 -s 0 host 192.168.88.4 and \( proto ICMP or port 2049 \) -w nfsdump
> > >>>>>
> > >>>>> on the client (192.168.88.2).  Next I mounted a directory on the client,
> > >>>>> and started reading (tar'ing) a directory into /dev/null.  It captured a
> > >>>>> few stalls.  Tcpdump shows number of packets it got, the stalls are at
> > >>>>> packet counts 58090, 97069 and 97071.  I cancelled the capture after that.
> > >>>>>
> > >>>>> The resulting file is available at http://www.corpit.ru/mjt/tmp/nfsdump.xz ,
> > >>>>> it is 220Mb uncompressed and 1.3Mb compressed.  The source files are
> > >>>>> 10 files of 1Gb each, all made by using `truncate' utility, so does not
> > >>>>> take place on disk at all.  This also makes it obvious that the issue
> > >>>>> does not depend on the speed of disk on the server (since in this case,
> > >>>>> the server disk isn't even in use).
> > >>>>
> > >>>> OK. So from the above file it looks as if the traffic is mainly READ
> > >>>> requests.
> > >>>
> > >>> The issue here happens only with reads.
> > >>>
> > >>>> In 2 places the server stops responding. In both cases, the client seems
> > >>>> to be sending a single TCP frame containing several COMPOUNDS containing
> > >>>> READ requests (which should be legal) just prior to the hang. When the
> > >>>> server doesn't respond, the client pings it with a RENEW, before it ends
> > >>>> up severing the TCP connection and then retransmitting.
> > >>>
> > >>> And sometimes -- speaking only from the behavour I've seen, not from the
> > >>> actual frames sent -- server does not respond to the RENEW too, in which
> > >>> case the client reports "nfs server no responding", and on the next
> > >>> renew it may actually respond.  This happens too, but much more rare.
> > >>>
> > >>> During these stalls, ie, when there's no network activity at all,
> > >>> the server NFSD threads are busy eating all available CPU.
> > >>>
> > >>> What does it all tell us? :)
> > >>>
> > >>> Thank you!
> > >>>
> > >>> /mjt
> > >>> --
> > >>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > >>> the body of a message to majordomo@vger.kernel.org
> > >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >>> Please read the FAQ at  http://www.tux.org/lkml/
> > >>
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
> > 
