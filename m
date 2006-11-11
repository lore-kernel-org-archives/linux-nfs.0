From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fail to start rpc nfsd
Date: Sat, 11 Nov 2006 13:04:20 -0500
Message-ID: <1163268260.6612.17.camel@lade.trondhjem.org>
References: <20061111145003.65766.qmail@web35210.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GixDd-0007lK-Qq
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 10:04:41 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/ikIfD6IuE2yFSc8NDUErVa982pc3+iKs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GixDd-0003gr-MF
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 10:04:43 -0800
To: Stephen Liu <satimis@yahoo.com>
In-Reply-To: <20061111145003.65766.qmail@web35210.mail.mud.yahoo.com>
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

On Sat, 2006-11-11 at 22:50 +0800, Stephen Liu wrote:
> Hi folks,
> 
> Ubuntu-6.06.1-LAMP-server-amd64
> 
> I'm following;
> https://help.ubuntu.com/ubuntu/serverguide/C/index.html
> Network File System (NFS)
> https://help.ubuntu.com/ubuntu/serverguide/C/network-file-system.html
> 
> to build a LAMP server which is for test only, not for production.
> Failed to start "nfs-kernel-server"
> 
> 
> $ sudo /etc/init.d/nfs-kernel-server start
> Password:
>  * Exporting directories for NFS kernel daemon...
> [ ok ]
>  * Starting rpc nfsd...                              [fail]
> 
> 
> $ cat /var/log/messages
> ........
> .........
> Nov 11 22:36:15 ubuntu kernel: [  563.144537] NFSD: Using
> /var/lib/nfs/v4recovery as the NFSv4 state recovery dire$Nov 11
> 22:36:15
> ubuntu kernel: [  563.144547] NFSD: recovery directory
> /var/lib/nfs/v4recovery doesn't exist
> Nov 11 22:36:15 ubuntu kernel: [  563.144550] NFSD: starting 90-second
> grace period
> Nov 11 22:36:50 ubuntu kernel: [  598.130968] portmap: server localhost
> not responding, timed out
> Nov 11 22:36:50 ubuntu kernel: [  598.130989] RPC: failed to contact
> portmap (errno -5).
> Nov 11 22:37:25 ubuntu kernel: [  633.112341] portmap: server localhost
> not responding, timed out
> Nov 11 22:37:25 ubuntu kernel: [  633.112361] RPC: failed to contact
> portmap (errno -5).
> Nov 11 22:38:00 ubuntu kernel: [  668.098108] portmap: server localhost
> not responding, timed out
> Nov 11 22:38:00 ubuntu kernel: [  668.098128] RPC: failed to contact
> portmap (errno -5).
> * end *
> 
> 
> Please advise how to fix the problem.  TIA 

sudo /etc/init.d/portmap start

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
