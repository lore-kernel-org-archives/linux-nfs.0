From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 17 Oct 2002 22:26:02 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021017.222602.48536782.taka@valinux.co.jp>
References: <012d01c27581$677d2180$2a060e09@beavis>
	<20021017.113126.102592502.taka@valinux.co.jp>
	<003301c275e1$0bf76810$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182Aly-0001Uh-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 06:33:10 -0700
To: habanero@us.ibm.com
In-Reply-To: <003301c275e1$0bf76810$2a060e09@beavis>
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

Hi,

> server: Udp: InDatagrams NoPorts InErrors OutDatagrams
>         Udp: 1000665 41 0 1000666
> clients: Udp: InDatagrams NoPorts InErrors OutDatagrams
>          Udp: 200403 0 0 200406
>          (all clients the same)

How about IP datagrams?  You can see the IP fields in /proc/net/snmp
IP layer may also discard them.

> > And how many threads did you start on your machine?
> > Buffer size of a UDP socket depends on number of kNFS threads.
> > Large number of threads might help you.
> 
> 128 threads.  client rsize=8196.  Server and client MTU is 1500.

It seems enough...



-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
