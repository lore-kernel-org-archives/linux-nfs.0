From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: umount warnings with "mountd only version 3"
Date: 27 Jan 2003 02:21:38 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6mj75gd.fsf@charged.uio.no>
References: <20030126224028.A26272@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030126224028.A26272@blackjesus.async.com.br>
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

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

Both are pure userland issues.

     > [Last email for the day, enough bothering for a Sunday] I've
     > made mountd here refuse version 1 and 2 requests (rpc.mountd -N
     > 2 -N 3), but as the FAQ itself states, we now get messages when
     > calling umount:

     > Bad UMNT RPC: RPC: Program/version mismatch; low version = 3,
     > high version = 3

Known issue with the 'umount' program. That's one of the fixes in the
patch

  http://www.fys.uio.no/~trondmy/src/util-linux-2.11n.dif.gz

     > And also, showmount has stopped working:

     > kiko@minastirith:~$ showmount -e anthem rpc mount export: RPC:
     > Program/version mismatch; low version = 3, high version = 3

No patch available, but should be pretty trivial to fix (provided
somebody is willing to put in the hours).

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
