From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: 17 Feb 2003 16:50:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsheb2lxde.fsf@charged.uio.no>
References: <3E50EC51.6022D3A7@moving-picture.com>
	<20030217152036.GA23116@terminus.zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,  nfs@lists.sourceforge.net,
	  autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18knXj-0007MQ-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 07:50:55 -0800
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <20030217152036.GA23116@terminus.zytor.com>
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

>>>>> " " == H Peter Anvin <hpa@zytor.com> writes:

     > Automount doesn't tell the server anything.  It's possible that
     > /bin/umount has this bug, however.

That is correct. In the util-linux implemention of 'umount' the RPC
call is done before the actual syscall.
My guess is that this was decided upon in order to avoid races for the
case where some other process does another 'mount'.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
