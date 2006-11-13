From: Stephen Liu <satimis@yahoo.com>
Subject: Re: Fail to start rpc nfsd
Date: Mon, 13 Nov 2006 09:13:42 +0800 (CST)
Message-ID: <20061113011342.22713.qmail@web35213.mail.mud.yahoo.com>
References: <20061113004930.GA22758@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjQOS-0000bT-Oz
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 17:13:49 -0800
Received: from web35213.mail.mud.yahoo.com ([66.163.179.92])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GjQOR-0002Xz-Nu
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 17:13:50 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061113004930.GA22758@fieldses.org>
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

Hi J. Bruce,

Tks for your advice.

> > $ ps -ef | egrep '/nfs-kernel-server'
> > satimis   4841  4786  0 08:16 pts/2    00:00:00 grep -E
> > /nfs-kernel-server
> 
> It's portmap you need to grep for.

$ ps -ef | egrep portmap
daemon    3513     1  0 07:58 ?        00:00:00 /sbin/portmap -i
127.0.0.1
satimis   4902  4786  0 09:01 pts/2    00:00:00 grep -E portmap
* end *

It is there.


Why each time on running;
$ sudo /etc/init.d/nfs-kernel-server restart
Password:
 * Stopping rpc mountd...                                              
                 [ ok ]
 * Stopping rpc nfsd...                                                
                 [ ok ]
 * Unexporting directories for NFS kernel daemon...                    
                 [ ok ]
 * Exporting directories for NFS kernel daemon...                      
                 [ ok ]
 * Starting rpc nfsd...                                                
                 [fail]
* end *

It hung on "Starting rpc nfsd..." a while before [fail] popup.  And
each time after "running apt-get upgrade" or after installing new
package it repeats running the above commands.  Finally failed.

Is there anyway to fix the said problem?  TIA


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
