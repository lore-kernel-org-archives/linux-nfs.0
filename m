From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat/Mandrake NFS - not playing nice
Date: 17 Feb 2003 20:16:17 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswujywwe6.fsf@charged.uio.no>
References: <3E5110B0.6000002@mleads.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kqkb-0004Je-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 11:16:25 -0800
To: santi@mleads.com
In-Reply-To: <3E5110B0.6000002@mleads.com>
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

>>>>> " " == santi  <Santiago> writes:

     > The Mandrake 9.0 is stock distro with kernel 2.4.19-ac4
     > (custom) with NFS support compiled in.

You appear to have forgotten to compile NFSv3 into this kernel. Try to
specify the option '-onfsvers=2'.

You appear also not to be running rpc.statd on that machine. Unless
you also use the 'nolock' mount option, you will end up with problems
the first time some process tries to lock a file.

Cheers,
 Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
