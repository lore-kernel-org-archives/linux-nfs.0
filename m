From: Matt Weatherford <mbw@u.washington.edu>
Subject: setclientid: string in use on NFS v4 share on Debian Etch &
 hosts file "solution"
Date: Wed, 07 Nov 2007 15:47:08 -0800
Message-ID: <47324E7C.4080808@u.washington.edu>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>	<20071107003940.13713.65472.stgit@heimdal.trondhjem.org>	<47323A62.9000803@oracle.com>
	<1194474763.7504.57.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpucK-0006sC-Jm
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:47:28 -0800
Received: from mxout7.cac.washington.edu ([140.142.32.178])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IpucQ-0004bo-7b
	for nfs@lists.sourceforge.net; Wed, 07 Nov 2007 15:47:34 -0800
In-Reply-To: <1194474763.7504.57.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi,

Im not sure this is the right place to ask, but Im wondering if someone can 
illuminate what the following console messages means on my NFS v4 server....


NFSD: setclientid: string in use by client(clientid 471c1b08/000003e9)
NFSD: setclientid: string in use by client(clientid 471c1b08/00000410)
nfs4_cb: server 10.11.12.221 not responding, timed out
nfs4_cb: server 10.11.12.222 not responding, timed out
NFSD: setclientid: string in use by client(clientid 471c1b08/0000043a)
NFSD: setclientid: string in use by client(clientid 471c1b08/0000043c)
NFSD: setclientid: string in use by client(clientid 471c1b08/00000447)
NFSD: setclientid: string in use by client(clientid 471c1b08/0000044d)
NFSD: setclientid: string in use by client(clientid 471c1b08/00000453)
nfs4_cb: server 10.11.12.221 not responding, timed out

(and yes, those IPs (10.11.12.221, 222) are good)


I am on Debian Etch, on x86 hardware, using multiple NFS v4 clients with
all the latest package updates.

I have multiple other NFS clients which the server is not complaining about.
I am sharing NFSv4 shares on both (2) NIC's.


NFS v4 client:

client42:~# uname -a
Linux client42 2.6.18-5-686 #1 SMP Wed Oct 3 00:12:50 UTC 2007 i686 GNU/Linux
client42:~# apt-show-versions | grep nfs
libnfsidmap2/etch uptodate 0.18-0
nfs-common/etch uptodate 1:1.0.10-6+etch.1
client42:~#


mount
client42:~# mount
...omittted non v4 shares...
yadda:/etch-llocal on /net/LLocal4 type nfs4 
(rw,hard,intr,rsize=32768,wsize=32768,addr=192.168.105.123)
client42:~>




NFS v4 server:

yadda:~# apt-show-versions | grep -i nfs
nfs-common/etch uptodate 1:1.0.10-6+etch.1
nfs-kernel-server/etch uptodate 1:1.0.10-6+etch.1
libnfsidmap2/etch uptodate 0.18-0
yadda:~#


Im not sure that this is the answer, but somewhere I saw a thread that I may 
need to name the host like this in my hosts table on my nfsv4 client:

127.0.0.1       localhost
127.0.1.1       client42

If this is the solution (is it?) ...this is a hassle, since I already have a 
hostname, and an IP address for that hostname defined in a hosts table that I 
push out to every cluster node and would like to keep them the same - is 
there another way to solve this problem that lets me keep all my hosts files
the same across my environment?

Thanks,

Matt




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
