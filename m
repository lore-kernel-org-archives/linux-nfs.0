From: war <war@lucidpixels.com>
Subject: Re: Kernel 2.4.21 Crashing (fwd)
Date: Mon, 11 Aug 2003 16:19:47 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.56.0308111617040.5520@p500>
References: <Pine.LNX.4.56.0308102113070.21263@p500> <200308111140.30727.bernd-schubert@web.de>
 <Pine.LNX.4.56.0308110856070.5520@p500> <200308112158.26799.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from lucidpixels.com ([66.45.37.187] ident=qmailr)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19mJ94-0003sC-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Aug 2003 13:19:58 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200308112158.26799.bernd-schubert@web.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I do not use ECC memory, I usually let memtest86 run 1-3 passes, which
takes 2-6 hours..

The CAS latency is 2.5, which is autodetected by SPD.

> Can you give more details about your hardware?
00:00.0 Host bridge: Intel Corp. 82875P Memory Controller Hub (rev 02)
00:01.0 PCI bridge: Intel Corp. 82875P Processor to AGP Controller (rev
02)
00:03.0 PCI bridge: Intel Corp. 82875P Processor to PCI to CSA Bridge (rev
02)
00:1d.0 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.1 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.2 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.3 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev c2)
00:1f.0 ISA bridge: Intel Corp. 82801EB LPC Interface Controller (rev 02)
00:1f.1 IDE interface: Intel Corp. 82801EB Ultra ATA Storage Controller
(rev 02)
00:1f.3 SMBus: Intel Corp. 82801EB SMBus Controller (rev 02)
00:1f.5 Multimedia audio controller: Intel Corp. 82801EB AC'97 Audio
Controller (rev 02)
01:00.0 VGA compatible controller: nVidia Corporation NV28 [GeForce4 Ti
4800 SE] (rev a1)
02:01.0 Ethernet controller: Intel Corp.: Unknown device 1019
03:02.0 FireWire (IEEE 1394): Texas Instruments TSB43AB23 IEEE-1394a-2000
Controller (PHY/Link)
03:04.0 Unknown mass storage controller: Promise Technology, Inc. 20269
(rev 02)
03:05.0 Ethernet controller: 3Com Corporation 3c905B 100BaseTX [Cyclone]
(rev 30)
03:06.0 Multimedia audio controller: Creative Labs SB Live! EMU10k1 (rev
07)
03:06.1 Input device controller: Creative Labs SB Live! MIDI/Game Port
(rev 07)
03:07.0 SCSI storage controller: Adaptec AHA-7850 (rev 03)

> Did you try to disable all non-needed, speed-, highmemory- and
agp-modules in
> your kernel configuration?
Yes, I disable everything that is not needed or required.

So far I have been copying a 20GB file over 100mbps @ 10MB+/s all day, no
crash yet, but I'll be leaving for a few hours, and while I'm away I'm
sure it will crash, so far::

war@war:~$ ./run.sh
2.91user 58.48system 30:39.85elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.10user 59.07system 30:37.82elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
2.96user 59.03system 30:43.24elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
2.99user 59.79system 30:27.49elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.06user 59.48system 30:26.57elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.20user 59.53system 30:39.49elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.20user 59.72system 30:27.38elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (110major+12minor)pagefaults 0swaps
2.80user 60.26system 30:29.12elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.41user 59.39system 33:17.08elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.13user 59.85system 30:25.33elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.33user 54.39system 34:48.79elapsed 2%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
3.00user 58.67system 32:31.53elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps
2.87user 60.65system 31:25.05elapsed 3%CPU (0avgtext+0avgdata
0maxresident)k
0inputs+0outputs (107major+12minor)pagefaults 0swaps

war@war:~$ cat run.sh
#!/bin/sh

log=copylog.txt
runs=0

while :
do
  echo "run $i @ `date`" >> $log
  echo "removing 20GB"  >> $log
  rm -f 20GB
  echo "syncing" >> $log
  sync
  echo "sleeping 10 sec" >> $log
  sleep 10
  echo "copying 20GB again" >> $log
  /usr/bin/time cp /p500/x/20GB . 2>&1 >> $log
done


We'll see..

I'm pretty sure it is not the memory, I am just unloading/not using
certain things each time to try and zero in on what exactly is causing the
problem, hopefully I'll find it.



On Mon, 11 Aug 2003, Bernd Schubert wrote:

> Hello,
>
> still looks like a memory error. How long did memtest86 run? We have some
> boards were memtest86 also finds no errors, but suddenly after an uptime of
> about 2 weeks, the ecc-module, detects single and multible bit errors. Any
> chance you use ecc-memory and monitor whats happens  when you copy the data?
> We think we solved this problem by simply adjusting the CAS-latency-bios
> setting to a higher value.
>
> Can you give more details about your hardware?
> E.g. our boards with serverworks-chipset had also had similar problems -
> solved with the last bios-update.
>
> Did you try to disable all non-needed, speed-, highmemory- and agp-modules in
> your kernel configuration?
>
> You might see that our group also rather often has related problems, so I just
> gave some hints based on my experience with such problems ;-)
>
> Best regards,
> 	Bernd
>
> On Monday 11 August 2003 14:56, war wrote:
> > Yes, I've run memtest86, it shows no errors.
> >
> > On Mon, 11 Aug 2003, Bernd Schubert wrote:
> > > Hi,
> > >
> > > just as usual, ever performed a memtest86-check? (all tests should be
> > > enabled)
> > >
> > > Regards,
> > > 	Bernd
> > >
> > > On Monday 11 August 2003 03:13, war wrote:
> > > > Has anyone else had a similiar problem?
> > > > Please cc me as I am not on the list.
> > > >
> > > > (These errors happen when I am transferring > 10GB files repeatedly
> > > > over NFS)
> > > >
> > > >
> > > > ---------- Forwarded message ----------
> > > > Date: Sun, 10 Aug 2003 21:09:06 -0400 (EDT)
> > > > From: war <war@lucidpixels.com>
> > > > To: linux-kernel@vger.kernel.org
> > > > Cc: kernelnewbies@nl.linux.org
> > > > Subject: Kernel 2.4.21 Crashing
> > > >
> > > > I am out of ideas as to what could cause this crashing...
> > > > Can anyone offer any suggestions as to what I should do next?
> > > >
> > > > war@war:~$ lsmod
> > > > Module                  Size  Used by    Not tainted
> > > > w83781d                20656   0
> > > > i2c-isa                 1160   0 (unused)
> > > > i2c-algo-pcf            5316   0 (unused)
> > > > i2c-algo-bit            7560   0 (unused)
> > > > i2c-dev                 4516   0 (unused)
> > > > i2c-proc                7216   0 [w83781d]
> > > > i2c-core               13028   0 [w83781d i2c-isa i2c-algo-pcf
> > > > i2c-algo-bit i2c-dev i2c-proc]
> > > > emu10k1                66284   0
> > > > ac97_codec             10356   0 [emu10k1]
> > > > sound                  58440   0 (unused)
> > > > war@war:~$
> > > >
> > > > Other than that, I am not using any binary-only modules or
> > > > applications.
> > > >
> > > > My X crashes randomly, my machine panicks, etc...
> > > >
> > > > I've compiled 2.4.20, 2.4.21, with gcc-3.2.3, gcc-3.3, both have the
> > > > same or similiar problems.
> > > >
> > > > I am out of ideas, I've tried all sorts of kernels, etc, re-installing
> > > > Slack 9.0, etc, I run the same setup on 2 other machines, and they work
> > > > fine, I've checked all the hardware (memory), (disk (on another
> > > > machine)), etc, it shows as OK.
> > > >
> > > > Should I try a windows variant (win2k,xp) and see if I get any crashes,
> > > > beucase at this point I am not sure what else to do?
> > > >
> > > > Unable to handle kernel NULL pointer dereference at virtual address
> > > > 00000000 printing eip:
> > > > c0131906
> > > > *pde = 00000000
> > > > Oops: 0002
> > > > CPU:    0
> > > > EIP:    0010:[<c0131906>]    Not tainted
> > > > EFLAGS: 00010246
> > > > eax: c0306a18   ebx: 00000000   ecx: c250fffc   edx: 00000000
> > > > esi: c250ffe0   edi: 0001328a   ebp: c0306c40   esp: c2821f40
> > > > ds: 0018   es: 0018   ss: 0018
> > > > Process kswapd (pid: 5, stackpage=c2821000)
> > > > Stack: c2095dd0 000001d0 000001ff 000001d0 00000016 0000001f 000001d0
> > > > 00000020 00000006 c0131ca3 00000006 c0306b90 c0306c40 000001d0 00000006
> > > > c0306c40 00000000 c0131d1e 00000020 c0306c40 00000002 c2820000 c0131e3c
> > > > c0306c40 Call Trace:    [<c0131ca3>] [<c0131d1e>] [<c0131e3c>]
> > > > [<c0131eb8>] [<c0131fe8>] [<c0131f50>] [<c0105000>] [<c01057ae>]
> > > > [<c0131f50>]
> > > >
> > > > Code: 89 02 c7 01 00 00 00 00 89 50 04 a1 18 6a 30 c0 89 48 04 89
> > > >  <1>Unable to handle kernel NULL pointer dereference at virtual address
> > > > 00000000 printing eip:
> > > > c0131906
> > > > *pde = 00000000
> > > > Oops: 0002
> > > > CPU:    0
> > > > EIP:    0010:[<c0131906>]    Not tainted
> > > > EFLAGS: 00010246
> > > > eax: c0306a18   ebx: 00000000   ecx: c250fffc   edx: 00000000
> > > > esi: c250ffe0   edi: 00013361   ebp: c0306c40   esp: e11c1e04
> > > > ds: 0018   es: 0018   ss: 0018
> > > > Process cp (pid: 8221, stackpage=e11c1000)
> > > > Stack: e11c1e38 c281916c 00000200 000001d2 00000020 00000020 000001d2
> > > > 00000020 00000006 c0131ca3 00000006 004be6f5 c0306c40 000001d2 00000006
> > > > c0306c40 00000000 c0131d1e 00000020 e11c0000 0000021f c0306c40 c0132ba4
> > > > 00000000 Call Trace:    [<c0131ca3>] [<c0131d1e>] [<c0132ba4>]
> > > > [<c0132e32>] [<c012ae99>] [<c012b4ff>] [<c012b77d>] [<c012bcf0>]
> > > > [<c012be82>] [<c012bcf0>] [<c01834a8>] [<c01399a3>] [<c01073df>]
> > > >
> > > > Code: 89 02 c7 01 00 00 00 00 89 50 04 a1 18 6a 30 c0 89 48 04 89
> > > >
> > > >
> > > >
> > > >
> > > > -------------------------------------------------------
> > > > This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> > > > Data Reports, E-commerce, Portals, and Forums are available now.
> > > > Download today and enter to win an XBOX or Visual Studio .NET.
> > > > http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_0
> > > >1/01 _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
