From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with Stale File Handles as non-root user
Date: 25 Jun 2002 00:20:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswusoz5da.fsf@charged.uio.no>
References: <20020624001859.A14403@cia.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17McBx-0003sb-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 15:20:13 -0700
To: Campbell McLeay <campbellm@cia.net.au>
In-Reply-To: <20020624001859.A14403@cia.net.au>
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

>>>>> " " == Campbell McLeay <campbellm@cia.net.au> writes:

     > AFAIK, there is no known network issue with the LAN (it works
     > fine as root always in any case).  The versions of nfs-server
     > and nfs-common on each machine are the latest debian versions
     > (i.e., 2.2beta47-4potato for the server and 0.1.9.1-1.potato
     > for nfs-common. The version of mount is 2.10f-5.1).


     > Any ideas on how to solve this problem would be greatly
     > appreciated.

Use knfsd instead of nfs-server. The userland nfs-server does not have
a reliable method for manipulating filehandles. In particular if the
filehandle falls out of the server's internal cache then it is not
always capable of recovering.

Cheers,
  Trond


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
