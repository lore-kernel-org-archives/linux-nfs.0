From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question about mounting....
Date: 31 Jan 2003 18:27:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsfzr9xmad.fsf@charged.uio.no>
References: <013001c2c949$b8a0d9a0$6601a8c0@userl3x55qxqed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18eewb-0006s0-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 09:27:14 -0800
To: "Matt Heaton" <admin@0catch.com>
In-Reply-To: <013001c2c949$b8a0d9a0$6601a8c0@userl3x55qxqed>
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

>>>>> " " == Matt Heaton <admin@0catch.com> writes:

     > mount point is just fine until the server comes back up and
     > then keeps going (It does this on our servers that use EXT3),
     > but on our

IIRC XFS loses the value of the fsid when it reboots. In recent
versions of the nfs-utils + server, you have an /etc/export option to
set the fsid to a fixed value.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
