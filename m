From: "David Shirley" <dave@cs.curtin.edu.au>
Subject: Re: Re: /var/lib/nfs/sm/ files
Date: Wed, 8 Jan 2003 16:08:42 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00ed01c2b6ed$2a9d9530$64070786@synack>
References: <20030107132743.E2628@blackjesus.async.com.br> <shsn0mcj3x8.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Christian Reis" <kiko@async.com.br>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Trond,

Will the client automatically remount or fix the mount
once the server comes back up? ie after the server
notifys the client, or does the client still have to restart
nfs?

Cheers
Dave


----- Original Message ----- 
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Christian Reis" <kiko@async.com.br>
Cc: <NFS@lists.sourceforge.net>; <linux-kernel@vger.kernel.org>
Sent: Wednesday, January 08, 2003 12:54 AM
Subject: [NFS] Re: /var/lib/nfs/sm/ files


> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > Hi there,
> 
>      > Can `anybody' (Neil, Trond?) explain what the entries in
>      > /var/lib/nfs/sm/ are for? If they refer to file locks, can we
> 
> 'man rpc.statd'. Those files store the IP-addresses of the machines
> being monitored by statd. In case of a crash or a reboot, those files
> tell statd which machines that need to be notified.
> 
> Cheers,
>   Trond
> 
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by:
> SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
> http://www.vasoftware.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
