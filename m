From: James Pearson <james-p@moving-picture.com>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Mon, 17 Feb 2003 17:49:56 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E5120C4.9C03C7A6@moving-picture.com>
References: <3E50EC51.6022D3A7@moving-picture.com>
		<20030217152036.GA23116@terminus.zytor.com>
		<shsheb2lxde.fsf@charged.uio.no>
		<3E510686.6899E7BE@moving-picture.com> <15953.2794.981629.182213@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>, nfs@lists.sourceforge.net,
 	autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kpPm-0005Bj-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 09:50:50 -0800
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

What would be the side effects of dropping the RPC call? I guess the
rpc.mountd on the server will never get a umount request - will this
cause problems with the client autofs repeatedly mounting/umounting file
systems from the server?

With my particular problem, there was nothing in the system log on the
client to indicate the the NFS filesystem couldn't be umounted - i.e.
under what circumstances could umount think it's OK to umount, but the
actual umount fails - if I try to umount an NFS filesystem that has open
resources, it get a 'device is busy' error.

Thanks

James Pearson

Trond Myklebust wrote:
> 
> >>>>> " " == James Pearson <james-p@moving-picture.com> writes:
> 
>      > So, is there a possible workround?  Thanks
> 
> Workaround: drop the entire RPC call. Failing that, you have a choice
> of races...
> 
> A real fix would involve teaching the knfsd kernel processes to do
> upcalls to userland in order to find out if a client is authorized or
> not. This is feasible in 2.5.x, but not in 2.4.x (as the latter lacks
> the machinery for doing upcalls to userland).
> 
> Cheers,
>   Trond
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
