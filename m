From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NetApp nfs server support tcp v3 root file system?
Date: Mon, 9 Sep 2002 13:03:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54E26@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17oUkq-0003Jr-00
	for <nfs@lists.sourceforge.net>; Mon, 09 Sep 2002 13:03:28 -0700
To: "'Hua Qin'" <qinhua@poisson.ecse.rpi.edu>
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

> I recreated the nfs root file on NetApp by using mounting udp 
> NFSv2, and I
> can boot the linux box using NFSv2 udp, while NetApp as a nfs 
> root file
> system.

good news.

> Then, I rebuild nfs root file by using NFSv3 tcp, and tried 
> to boot the
> linux box using NFSv3 tcp. But it failed. So I have to go back to my
> first question: is there any issue about NetApp be a  nfs 
> server servered
> as NFSv3 tcp protocol? I asked this because I think NetApp 
> support NFSv3
> tcp server, and linux box can suppport NFSv3 client.

i'm not aware of any issues on the filer side that might contribute
to this problem.

were you ever able to boot diskless Linux with TCP and v3 from
any other server?  i wonder if nfsroot is broken over TCP?


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
