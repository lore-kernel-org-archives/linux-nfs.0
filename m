From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench
	2.0
Date: Sun, 3 Nov 2002 09:05:02 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55047@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188OBT-00020P-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Nov 2002 09:05:11 -0800
To: "'Andrew Ryan'" <andrewr@nam-shub.com>
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

> > >It is probably just the (known) accounting error in the 'retransmit' 
> > >statistics. Try applying the patch
> > >
> > > 
> > >http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-0
1-call_start.dif
> >
> >if it bothers you.
> 
> Yes, you are right, it seems the counter is broken, and performance is 
> fine. I did bonnie++ runs with 2.4.20rc1 kernels with and without the 
> call_start patch, and didn't see any significant difference.

the call_start patch only changes RPC accounting.  it should have no
effects (either positive or negative) on performance.

did you try the xprt_write_space patch?  that fixes a real problem,
and addresses the root cause of the high retransmission counts you see.

> But, it does bother me since I want to be able to diagnose network errors 
> if I ever have them, and with a busted counter it will be impossible to 
> tell what my real error rate is. 

the retransmit counter is supposed to count only whole RPC retransmissions,
not TCP partial transmissions, which are not due to network problems.  if
the xprt_write_space patch was included, the false retransmit rate would
be much lower anyway (although not zero).

> Can the call_start patch go to Marcelo for 2.4.20rc2?

call_start is available in Trond's NFS_ALL patch for now.  i think 2.4.20
is closed for changes like this.


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
