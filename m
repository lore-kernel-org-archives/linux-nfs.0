From: Andrew Ryan <andrewr@nam-shub.com>
Subject: RE: 2.4.20-rc1 NFS/TCP client (still) hangs running
  dbench  2.0
Date: Mon, 04 Nov 2002 08:51:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20021104084821.02434b30@pop.sfrn.dnai.com>
References: <6440EA1A6AA1D5118C6900902745938E07D55047@black.eng.netapp.
 com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smithers.sfrn.dnai.com ([208.59.199.26])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188kPA-0006kS-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 08:48:48 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D55047@black.eng.netapp.
 com>
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

At 09:05 AM 11/3/02 -0800, Lever, Charles wrote:

>did you try the xprt_write_space patch?  that fixes a real problem,
>and addresses the root cause of the high retransmission counts you see.

Has this patch been posted on Trond's site? If so can you refer me to it? 
It's not marked under the 2.4.20 directory. If it hasn't been posted, can 
it be?


>call_start is available in Trond's NFS_ALL patch for now.  i think 2.4.20
>is closed for changes like this.

OK, fair enough.



-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
