From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: should NLM locks send notifications after nfsd crash
Date: Fri, 1 Apr 2005 12:14:03 +1000
Message-ID: <16972.44651.280877.472381@cse.unsw.edu.au>
References: <20050331131327.GB1328@hmsendeavour.rdu.redhat.com>
	<1112285953.12388.17.camel@lade.trondhjem.org>
	<20050401015641.GB5562@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHBfs-0000J8-2f
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:14:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DHBfq-0001Fa-LA
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:14:16 -0800
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: message from Neil Horman on Thursday March 31
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday March 31, nhorman@redhat.com wrote:
> 
> Thank you for the through explination Trond, its apperciated. This only leaves
> 1 question in my mind: Specifically under the Linux nfs server, does a stopping
> and starting of nfsd (but specifically _not_ rpc.lockd or rpc.statd) constitute
> a loss of NLM state?
> 

Uhmm... it depends.

Stopping the nfsd server threads does not, itself, cause a loss of
locking state.
However unexporting the filesystems does, and this often accompanies
the stopping of the last thread.
To be specific:
  If the last thread dies due to SIGHUP, or though an explicit setting
  of the number of threads to 0:
     rpc.nfsd 0
  then the filesystems aren't unexported, and locking state remains.
  (unless you explicitly exportfs -avu)

  If the last thread dies due to any other signal (KILL, INT, QUIT),
  then the filesystems are explicitly unexported which will cause
  locking state to be lost.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
