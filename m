From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 32k NFS blocksize not working
Date: 12 Mar 2003 23:41:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy93kky14.fsf@charged.uio.no>
References: <1047488992.6343.2.camel@batman.ece.rice.edu>
	<1047506146.6666.11.camel@batman.ece.rice.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18tEvH-0006wf-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Mar 2003 14:42:07 -0800
To: Brent Clements <bclem@rice.edu>
In-Reply-To: <1047506146.6666.11.camel@batman.ece.rice.edu>
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

>>>>> " " == Brent Clements <bclem@rice.edu> writes:

     > We have a linux server running 2.4.20 plus it has nfsv3 udp/tcp
     > server support compiled in.

     > We have a linux client running 2.4.20 plus it has nfsv3 udp/tcp
     > client support compiled.


     > If we specify a read/write size above 8192 on the client, and
     > then mount the nfs directory. It gives us the following on
     > /proc/mounts


     > cluster:/usr/local/ /tmp/d nfs
     > rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=cluster 0 0

     > Do we have to edit something in a kernel include file to allow
     > NFSV3 to mount above 8k?

You'll have to find a server which supports it. Linux 2.4.x knfsd as
it stands, supports only 8k, and so the client will override any
attempt that you make to set either rsize or wsize > 8k.

If you are feeling brave, you might try to change the value of
NFSSVC_MAXBLKSIZE in include/linux/nfsd/const.h and recompiling the
server.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
