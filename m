From: Matthew Mitchell <matthew@geodev.com>
Subject: Re: mmap() and NFS server performance
Date: Mon, 16 Dec 2002 14:04:01 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DFE31B1.40306@geodev.com>
References: <3DFA4C9A.50101@geodev.com>	<shsadj826bt.fsf@charged.uio.no>	<3DFDE455.1000004@geodev.com> <15869.59466.167433.194706@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[QNCnXdb1HP3jtZrPFNSx1xfCfzCaYAob])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O1X1-0000kK-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 12:08:03 -0800
To: trond.myklebust@fys.uio.no
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

Trond Myklebust wrote:
>>>>>>" " == Matthew Mitchell <matthew@geodev.com> writes:
>>>>>
> 
>      > 1) What would you like to see, tcpdump/snoop wise, to verify
>      >    this?
> 
> nfsstat on the client should normally tell you how often you are
> seeing RPC retransmits.

Ran the program again.  In 20 minutes, around 20k total client RPC 
requests, with an assortment of retrans, time, and badxid errors.  I am 
starting to believe that there is a problem using UDP, and that it alone 
might be enough to explain the slowness.   It seems to have negotiated 
an 8k transfer size.  Reasonable?

>      > 2) Could UDP service really be causing this order of magnitude
>      >    slowdown?
> 
> Certainly: retransmissions follow an *exponential* backoff rule. For
> that reason, it doesn't take a very high percentage of retransmissions
> before you see a large impact.

Seems to be borne out by the evidence.

>      > 3) Is TCP server code "ready enough" for production use?  In
>      >    our case we
>      > don't mind some occasional bugs, but it needs to be able to
>      > stay working under reasonable load for a day or so at a time
>      > for us to get anything done ("Stale NFS file handle" is a
>      > scourge...).
> 
> That is more of a question for Neil Brown, but I personally don't have
> any particularly bad experiences to report.

Any particularly *good* ones? :)  Would you recommend the 2.4.20 set, or 
some additional patches?  I will probably install the new kernel when we 
get a little downtime later this week (and then I will promptly go on 
vacation; hope it stays up! ha!).

Thanks for the suggestions and assistance.  I'll report back with TCP 
info for anyone who is interested.

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
