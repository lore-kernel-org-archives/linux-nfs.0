From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 17 Oct 2002 08:16:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003301c275e1$0bf76810$2a060e09@beavis>
References: <15788.57476.858253.961941@notabene.cse.unsw.edu.au><20021015.213102.80213000.davem@redhat.com><012d01c27581$677d2180$2a060e09@beavis> <20021017.113126.102592502.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <neilb@cse.unsw.edu.au>, <davem@redhat.com>,
        <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182AbM-0006wl-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 06:22:13 -0700
To: "Hirokazu Takahashi" <taka@valinux.co.jp>
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

Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36


> Hello,
>
> Thanks for testing my patches.
>
> > I am still seeing some sort of problem on an 8 way (hyperthreaded 8
> > logical/4 physical) on UDP with these patches.  I cannot get more than 2
> > NFSd threads in a run state at one time.  TCP usually has 8 or more.
The
> > test involves 40 100Mbit clients reading a 200 MB file on one server (4
> > acenic adapters) in cache.  I am fighting some other issues at the
moment
> > (acpi wierdness), but so far before the patches, 82 MB/sec for NFSv2,UDP
and
> > 138 MB/sec for NFSv2,TCP.  With the patches, 115 MB/sec for NFSv2,UDP
and
> > 181 MB/sec for NFSv2,TCP.  One CPU is maxed due to acpi int storm, so I
> > think the results will get better.  I'm not sure what other lock or
> > contention point this is hitting on UDP.  If there is anything I can do
to
> > help, please let me know, thanks.
>
> I guess some UDP packets might be lost. It may happen easily as UDP
protocol
> doesn't support flow control.
> Can you check how many errors has happened?
> You can see them in /proc/net/snmp of the server and the clients.

server: Udp: InDatagrams NoPorts InErrors OutDatagrams
        Udp: 1000665 41 0 1000666

clients: Udp: InDatagrams NoPorts InErrors OutDatagrams
         Udp: 200403 0 0 200406
         (all clients the same)

> And how many threads did you start on your machine?
> Buffer size of a UDP socket depends on number of kNFS threads.
> Large number of threads might help you.

128 threads.  client rsize=8196.  Server and client MTU is 1500.

Andrew Theurer



-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
