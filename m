From: Matt C <wago@phlinux.com>
Subject: RE: 3 NFS client panics in 2.4.21. Fixed in 2.4.22?
Date: Tue, 26 Aug 2003 10:24:16 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0308261008490.5065-100000@fubar.phlinux.com>
References: <482A3FA0050D21419C269D13989C6113D06B5B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19riO1-0002tF-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Aug 2003 11:17:45 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19riO0-0000T9-Nh
	for nfs@lists.sourceforge.net; Tue, 26 Aug 2003 11:17:44 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113D06B5B@lavender-fe.eng.netapp.com>
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

Hi Chuck-

You're correct, of course: The NFS OOPSes that I got are not related to 
the problem that was fixed by the patch submitted by Trond a couple days 
ago.

All the machines that had the problem are SMP, and all have 4GB of RAM
(but PAE is disabled in our kernels). 2 machines are HP NetServer
LT6000Rs, with 6 CPUs. The other machine is an HP Proliant DL380G3 server,
which is a 2P xeon box.

We haven't seen the problem on any UP systems, nor have we seen it on
non-highmem systems. However, most of our hosts are larger SMP boxes, so
most of our apps just won't work in the UP or 1G space, unfortunately.

Of the hosts that crashed, one is both an NFS client and server, and the
rest are just clients. All hosts are using autofs to automount NFS
mounts in /net. The NFS mount flags are:
rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock

2 of the hosts are using the e100 network chipset, and the third is using 
the tg3 chipset, but all are running at 100FD.

The servers being mounted are a mix of 2.4 linux hosts and a few netapp 
filers. The mount flags are the same for all mounts.

Thanks!

-matt

On Tue, 26 Aug 2003, Lever, Charles wrote:

> > > I've had 3 very similar panics on 3 seperate machines under 
> > 2.4.21. All
> > > appear to be in the NFS client stack. All are SMP/Bigmem 
> > machines, and the
> > > kernel was pretty close to vanilla. All machines are 
> > redhat-7.2 using ext3
> > > filesystems.
> > >
> > > Before I hop on the latest kernel out of the hopper for production
> > > systems, do you know if these are known/fixed bugs in 
> > 2.4.22 or in BK?
> > >
> >  
> > I'm afraid there is a critical bug in 2.4.22, please see the thread:
> > 
> > [NFS] nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
> > 
> > 
> > I havn't tested it with 2.4.22-rc3 and rc4, but I didn't see 
> > anything in the 
> > changelog, that could fix it :-(
> 
> the "nfs errors clutter up logs" bug has nothing to do with these
> oopses, as far as i can tell.
> 
> matt-  can you tell us a little about how you reproduce this problem?
> have you ever seen it on UP or non-HIGHMEM systems?
> 



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
