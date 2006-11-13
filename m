From: Stephen Liu <satimis@yahoo.com>
Subject: Re: Fail to start rpc nfsd
Date: Mon, 13 Nov 2006 12:10:23 +0800 (CST)
Message-ID: <20061113041023.41362.qmail@web35205.mail.mud.yahoo.com>
References: <1163388941.5736.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjT9S-0007tI-05
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 20:10:30 -0800
Received: from web35205.mail.mud.yahoo.com ([66.163.179.84])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GjT9Q-0005Zr-VK
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 20:10:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1163388941.5736.8.camel@lade.trondhjem.org>
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


> > > > $ ps -ef | egrep '/nfs-kernel-server'
> > > > satimis   4841  4786  0 08:16 pts/2    00:00:00 grep -E
> > > > /nfs-kernel-server
> > > 
> > > It's portmap you need to grep for.
> > 
> > $ ps -ef | egrep portmap
> > daemon    3513     1  0 07:58 ?        00:00:00 /sbin/portmap -i
> > 127.0.0.1
> > satimis   4902  4786  0 09:01 pts/2    00:00:00 grep -E portmap
> > * end *
> > 
> > It is there.
> 
> Check that you don't have an entry in /etc/hosts.deny that is
> blocking
> access to portmap.

Nothing enabled on /etc/hosts.deny file.  Just retain its original file
without touched.


> Also check that you don't have any iptables
> entries
> that are doing the same.

$ sudo iptables --list
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
TCPMSS     tcp  --  anywhere             anywhere            tcp
flags:SYN,RST/SYN tcpmss match 1400:1536 TCPMSS clamp to PMTU
ACCEPT     all  --  192.168.0.0/16       anywhere
ACCEPT     all  --  anywhere             192.168.0.0/16      state
RELATED,ESTABLISHED

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
* end *


$ sudo /etc/init.d/nfs-kernel-server restart
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

Failed.


$ sudo /etc/init.d/nfs-kernel-server force-reload
 * Re-exporting directories for NFS kernel daemon...                   
 [ ok ]
* end *

But "force-reload" was OK

Tks.


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
