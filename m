From: Hua Qin <qinhua@poisson.ecse.rpi.edu>
Subject: RE: NetApp nfs server support tcp v3 root file system?
Date: Mon, 9 Sep 2002 17:19:43 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.10.10209091710100.1027-100000@poisson.ecse.rpi.edu>
References: <6440EA1A6AA1D5118C6900902745938E07D54E26@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rpi.edu ([128.113.22.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17oVwm-00006S-00
	for <nfs@lists.sourceforge.net>; Mon, 09 Sep 2002 14:19:52 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D54E26@black.eng.netapp.com>
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

In kernel 2.4.7, there is a known issue about  linux as nfs server in
TCP,v3, so I can not even mount between two linux boxes over TCP.

But linux box nfs client over tcp works fine, I tested it by using linux
box as a nfs client (tcp,v3), and NetApp as a nfs server. The linux box
can sucessfully mount over tpc,v3, however another diskless linux can not
boot from NetApp  nfsroot. It stuck at mounting NetApp server, and the
error in EIO (I/O error).

I am just wondering if someone did the simlar test before.

Thanks!
Hua   



On Mon, 9 Sep 2002, Lever, Charles wrote:

> > I recreated the nfs root file on NetApp by using mounting udp 
> > NFSv2, and I
> > can boot the linux box using NFSv2 udp, while NetApp as a nfs 
> > root file
> > system.
> 
> good news.
> 
> > Then, I rebuild nfs root file by using NFSv3 tcp, and tried 
> > to boot the
> > linux box using NFSv3 tcp. But it failed. So I have to go back to my
> > first question: is there any issue about NetApp be a  nfs 
> > server servered
> > as NFSv3 tcp protocol? I asked this because I think NetApp 
> > support NFSv3
> > tcp server, and linux box can suppport NFSv3 client.
> 
> i'm not aware of any issues on the filer side that might contribute
> to this problem.
> 
> were you ever able to boot diskless Linux with TCP and v3 from
> any other server?  i wonder if nfsroot is broken over TCP?
> 



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
