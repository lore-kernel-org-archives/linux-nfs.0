From: Stephen Liu <satimis@yahoo.com>
Subject: Re: Fail to start rpc nfsd
Date: Sun, 12 Nov 2006 08:17:31 +0800 (CST)
Message-ID: <20061112001731.49149.qmail@web35208.mail.mud.yahoo.com>
References: <1163268260.6612.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gj32X-00086O-5N
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 16:17:40 -0800
Received: from web35208.mail.mud.yahoo.com ([66.163.179.87])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Gj32W-0006Zg-UH
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 16:17:38 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1163268260.6612.17.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Trond,

Tks for your advice.

> > I'm following;
> > https://help.ubuntu.com/ubuntu/serverguide/C/index.html
> > Network File System (NFS)
> >
> https://help.ubuntu.com/ubuntu/serverguide/C/network-file-system.html
> > 
> > to build a LAMP server which is for test only, not for production.
> > Failed to start "nfs-kernel-server"
> > 
> > 
> > $ sudo /etc/init.d/nfs-kernel-server start
> > Password:
> >  * Exporting directories for NFS kernel daemon...
> > [ ok ]
> >  * Starting rpc nfsd...                              [fail]

- snip -

> > Please advise how to fix the problem.  TIA 
> 
> sudo /etc/init.d/portmap start

$ sudo /etc/init.d/portmap start
Password:

 * Not starting portmap daemon.  Already running.     [ ok ]
* end *

It said already running.

What will be this command for;
/etc/init.d/nfs-kernel-server start


Each time after running "apt-get upgrade" or installing a new package,
it will automatically run the said command at the end.  It hung there
for a while before [fail] popup.  How to fix it.  TIA.

B.R.
Stephen

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
