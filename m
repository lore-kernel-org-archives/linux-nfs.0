From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RedHat 7.3 crashed NetApp?
Date: Fri, 17 May 2002 15:17:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CF34@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178q30-0003jg-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 15:18:02 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01-a.netapp.com (8.11.1/8.11.1/NTAP-1.2) with ESMTP id g4HMHtA06007
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 15:17:55 -0700 (PDT)
Received: from tahoe.corp.netapp.com (localhost [127.0.0.1])
	by frejya.corp.netapp.com (8.12.2/8.12.2/NTAP-1.4) with ESMTP id g4HMHshn025422
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 15:17:54 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

i'm wondering what are the common elements here:

is the EEpro 100 ethernet card common to all clients
that exhibit this problem?  NFSv3 over UDP?  what is
the nature of the network flood -- ICMP packets, or
UDP?  does "top" on the client show whether a particular
process or processes is spinning?

a tcpdump or at least "netstat -s" on the client after
the network is unplugged might be helpful.

> -----Original Message-----
> From: Cooke, Alan [mailto:acooke@hp.com]
> Sent: Friday, May 17, 2002 9:15 AM
> To: nfs@lists.sourceforge.net
> Subject: RE: [NFS] RedHat 7.3 crashed NetApp?
> 
> 
> While running the 2.4.18-4smp kernel (RedHat), and testing 
> NFS3, our NetApp filer running OnTap 6.1.1R2 experienced 
> massive incoming traffic from the Linux client in question. 
> The Linux client required rebooting. We have been able to 
> repeat this behavior, and are suspicious of the network 
> driver on the Linux client which is using the eth0 driver. A
> 
> Sound familiar?
> 
> Alan Cooke
> Hewlett-Packard Company
> ISS/EDA
> Office: 281-518-9775
> Fax    : 281-518-8015
> Email  : acooke@hp.com
> 
> "If everything seems under control, you're just not going 
> fast enough."
> -- Mario Andretti
> 
> 
> 
> 
> 
> 
> 
> 
> -----Original Message-----
> From: H . J . Lu [mailto:hjl@lucon.org]
> Sent: Thursday, May 16, 2002 5:39 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] RedHat 7.3 crashed NetApp?
> 
> 
> Has anyone seen
> 
> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=65069
> 
> 
> H.J.
> 
> _______________________________________________________________
> 
> Have big pipes? SourceForge.net is looking for download 
> mirrors. We supply
> the hardware. You get the recognition. Email Us: 
> bandwidth@sourceforge.net
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> _______________________________________________________________
> 
> Have big pipes? SourceForge.net is looking for download 
> mirrors. We supply
> the hardware. You get the recognition. Email Us: 
> bandwidth@sourceforge.net
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
