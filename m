From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: /var/lib/nfs/sm/ files
Date: Wed, 8 Jan 2003 10:13:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301081013.59384.trond.myklebust@fys.uio.no>
References: <20030107132743.E2628@blackjesus.async.com.br> <shsn0mcj3x8.fsf@charged.uio.no> <00ed01c2b6ed$2a9d9530$64070786@synack>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: "David Shirley" <dave@cs.curtin.edu.au>,
 "Christian Reis" <kiko@async.com.br>
In-Reply-To: <00ed01c2b6ed$2a9d9530$64070786@synack>
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

On Wednesday 08 January 2003 09:08, David Shirley wrote:
> Trond,
>
> Will the client automatically remount or fix the mount
> once the server comes back up? ie after the server
> notifys the client, or does the client still have to restart
> nfs?

If the client and server both comply with the NFS standards, then the client 
should never have to remount after a server reboot. rpc.statd exists purely 
for the benefit of the NFS file locking.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
