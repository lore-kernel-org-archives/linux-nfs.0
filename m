From: James Pearson <james-p@moving-picture.com>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Mon, 17 Feb 2003 15:57:58 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E510686.6899E7BE@moving-picture.com>
References: <3E50EC51.6022D3A7@moving-picture.com>
		<20030217152036.GA23116@terminus.zytor.com> <shsheb2lxde.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>, nfs@lists.sourceforge.net,
 	autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18knfN-0000Kr-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 07:58:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

So, is there a possible workround?

Thanks

James Pearson

Trond Myklebust wrote:
> 
> >>>>> " " == H Peter Anvin <hpa@zytor.com> writes:
> 
>      > Automount doesn't tell the server anything.  It's possible that
>      > /bin/umount has this bug, however.
> 
> That is correct. In the util-linux implemention of 'umount' the RPC
> call is done before the actual syscall.
> My guess is that this was decided upon in order to avoid races for the
> case where some other process does another 'mount'.
> 
> Cheers,
>   Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
