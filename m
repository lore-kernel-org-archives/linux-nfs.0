From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 13:28:50 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
References: <1070016521.3615.26.camel@wibbit.firebox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APhk6-0000N2-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 04:29:02 -0800
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APhk6-0003Kt-8C
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 04:29:02 -0800
To: Douglas Furlong <douglas.furlong@firebox.com>
In-Reply-To: <1070016521.3615.26.camel@wibbit.firebox.com>
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

On Fri, 28 Nov 2003, Douglas Furlong wrote:

> On Fri, 2003-11-28 at 10:11, Juergen Sauer wrote:
> > Using 2.4.18-XFS all is fine, except the speed of the IDE System,
> > Using 2.4.22-XFS mostly IDE Speed is fine, System runs fine, 

There's a big time and code difference between 2.4.18 and 2.4.22.

> What in your opinion is a lot of retransmissions? Today I am seeing
> around 0.7%.

I also see something like 0.8-1% retransmissions and these messages on
newly installed Fedora Core 1 on some cluster nodes, using default r/wsize
(8192). As I'm using root-NFS, the node is quite useless when this
situation happens. I'm sure that the network is not the problem in my
case. The nodes used to run various kernels between 2.4.9 and 2.4.18, now
running the FC1 kernel recompiled with config changed to add root FS on
NFS and IP autoconfig and include 3c59x driver in kernel.
The NFS server was recently upgraded to a faster CPU and disk system. It 
used to run whatever kernel updates Red Hat released and now it's also 
running FC1 with its default kernel (2.4.22-based).

So far, I haven't had time to take a look at the conditions when this 
happens. One sure way to trigger it is however to leave the default Red 
Hat cron jobs enabled on several tens of time-synchronized nodes all 
having the root FS exported from a single server - the "slocate" daily 
cron job will create serious NFS activity. However this did not happen 
with the older setup (RH kernels on server and 2.4.9-2.4.18 kernels on 
clients).

The load on the server when simultaneously rebooting several tens of nodes
goes up to 10-12, while previously it was 3-5. IMHO, this points more to a
slower/less-efficient NFS daemon or to a more agressive client (but which 
gives up easier afterwards as seen from the logged messages).

> I am using the standard kernel provided by redhat for this machine.

Might the Red Hat kernel be the problem ? I can't test for the moment 
other kernels...

> > But it's possible to configure that it does not hurt too much, by lowering
> > rsize=4096,wsize=4096 I got a compromise between speed and "NFS server ...".

Or as Trond suggested increase "retrans"; I'm actually booting these node
with "intr,v3,timeo=15,retrans=7" on the kernel command line and the
messages don't appear as often as with the default values. I haven't got
any clue as to how to choose the values, only that the documentation said
"increase".

> Neither the open-source nor closed source drivers appear to be loaded,
> are these drivers only loaded when going to runlevel 5 (or starting x
> manually?)?

Also in my case there's no NVIDIA at all (AMD chipset, 3C905C NIC, cheap 
ATI graphics which is used only in text mode).

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
