From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS UDP firewall reassemble failure
Date: 22 Mar 2002 01:54:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1yedl8wm.fsf@charged.uio.no>
References: <00300496.C21145@alliedtelesyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oDJs-0004x1-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 16:54:13 -0800
To: shem_page@alliedtelesyn.com
In-Reply-To: <00300496.C21145@alliedtelesyn.com>
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

>>>>> " " == Shem Page <shem_page@alliedtelesyn.com> writes:

     >  So after quickly scanning some Man Pages, and also searching
     >  this archive, I
     > couldn't find any hint at how to restrict Mount, or NFSD to a
     > limited packet size.

You can't do this on the server side, however you can on the client side:
just specify the options 'rsize=1024,wsize=1024' in /etc/fstab.

Alternatively, if you have applied Neil's TCP server patches (see
http://cgi.cse.unsw.edu.au/~neilb/patches/linux-stable), you might
instead specify the 'tcp' mount option - again on the client.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
