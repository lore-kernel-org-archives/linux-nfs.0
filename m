From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ~800 mountpoint limitation
Date: 17 Oct 2003 10:55:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvfqnykvs.fsf@charged.uio.no>
References: <482A3FA0050D21419C269D13989C6113020AC50F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ogden, Aaron A." <aogden@unocal.com>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAiPQ-0000LT-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 21:09:44 -0700
Received: from [198.186.202.147] (helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAW4y-0000K7-Jj
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 07:59:48 -0700
Received: from pat.uio.no ([129.240.130.16]:58112)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1AAW0W-0000IC-6K
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 07:55:12 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113020AC50F@lavender-fe.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > trond has heard my complaints about this before....  sharing an
     > RPC transport socket across mounts is an interesting solution
     > in some ways, but i'm concerned about the performance
     > scalability of this solution, especially since the RPC slot
     > table size is fixed at a relatively small 16 entries.

The answer to this problem is to make the slot table size
configurable. I believe you even have a patch for that, Chuck ;-)

     > imagine sharing 16 RPC slots across all the mounts on a very
     > busy multi-user system.  if one mount backs up (say because one
     > of the server's disks gets busy), that makes all the mounts
     > sharing that slot table unusable.


I'm not really sure that I buy the argument about the server disks
getting busy. That will tend to hit you whether or not you are sharing
RPC slots, since it also ties up server resources.

The main point with putting all the transport to a given server on one
socket is that the UDP/TCP congestion control algorithms can then
function efficiently. Instead of competing against other packets
originating from itself, the client only has to deal with competition
from other clients.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
