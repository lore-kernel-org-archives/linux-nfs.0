From: Erik Forsberg <forsberg+nfs@cendio.se>
Subject: Configuration recommendations for Linux Terminal Server Usage?
Date: Tue, 29 Aug 2006 10:37:20 +0200
Message-ID: <uopsekndj3.fsf@impertigo.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GHz6E-00033F-V6
	for nfs@lists.sourceforge.net; Tue, 29 Aug 2006 01:37:35 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GHz6E-00015z-3S
	for nfs@lists.sourceforge.net; Tue, 29 Aug 2006 01:37:35 -0700
Received: from impertigo.lkpg.cendio.se (dhcp-252-48.lkpg.cendio.se
	[10.47.252.48]) by mail.cendio.se (Postfix) with ESMTP id 5548C25DB24
	for <nfs@lists.sourceforge.net>; Tue, 29 Aug 2006 10:37:24 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi!

We have a customer running about 10 "client servers" (SuSE Linux 9.3,
2.6.11.4-21.13-bigsmp) with the homedirectories being served by an NFS
server running SuSE 10.1 (2.6.16.13-4-bigsmp).

Each "client server" typically hosts about 40 concurrent users with
their own session (terminal session via ThinLinc). The home
directories are automounted, so there's one mount per active user. The
load from each user varies, being rather low when they only run
firefox/Openoffice etc, sometimes going up when they start
applications that have the mishabit to copy hundreds of files into the
home directory. 

We've experienced slow NFS performance in this cluster, but the
problem disappeared when we raised the number of nfsd instances on the
server to 100. 40 was to low. To me, 100 seems like a rather high
number, reading the NFS FAQ which seems to recommend 4-8 threads per
processor (this machine has 2 HT processors, so /proc/cpuinfo lists 4
processors). 

What's the recommended configuration of Linux NFS client and server in
this kind of situation (moderate amount of NFS clients, all of them
generating a lot of traffic)?

* UDP or TCP? 
* Recommended number of nfsd instances on server? 
* Automount or not (not strictly neccesary, there's only one
  /export/home with a flat structure, so we could remove the
  automounter)
* Something else?

The th line in /proc/net/rpc/nfds looks like this:

th 100 1089236 2344.512 4635.584 497.360 587.508 327.080 35.468 189.708 10.484 7.248 368.336

I don't know how accurate that line is - the server has not been
restarted since we raised the number of nfsd daemons to 100, so it
could contain measurements from the time when there were too few. 

Thanks,
\EF
-- 
Erik Forsberg                OpenSource-based Thin Client Technology
Systems Analyst/Developer    Phone: +46-13-21 46 00    
Cendio AB    	             Web: http://www.cendio.com
		             


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
