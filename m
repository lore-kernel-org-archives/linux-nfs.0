From: Steffen Persvold <sp@scali.com>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Fri, 24 May 2002 13:43:54 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0205241316260.3144-100000@sp-home.isdn.scali.no>
References: <200205141437.26169.trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BDZg-0002NS-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 04:49:36 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200205141437.26169.trond.myklebust@fys.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 14 May 2002, Trond Myklebust wrote:

> Tysdag 14. mai 2002 13:15 skreiv Steffen Persvold:
>
> > > If you want to run a 2.2. client, then grab 2.2.21-rc2, and apply the
> > > patch from
> > >
> > >   http://www.fys.uio.no/~trondmy/src/2.2.21-rc2/linux-2.2.21-NFS.dif
> >
> > Do I have to ?
>
> Not if you can live with the bugs ;-)
>
> > Will it fix my problem ? Other known NFS bugs ?
>
> The 2.2.21-NFS patch fixes all the EIO bugs that were found in 2.4.x. You
> might of course have found totally different bugs, but I really can't tell
> until you eliminate the first possibility.
>


Hi again,

I have some updates on this problem. As you may remember I had a RH 7.2
NFS server (i686) running the 2.4.9-21smp kernel, exporting an ext2
directory (~70GB).

Sometimes I discovered problems when linking together a large static
library on two clients which had different architecture (ia32 ia64), both
running RedHat but with different kernels (ia32 was running 2.2.19-6.2.7
and ia64 was running a stock 2.4.18 with ia64 patchset). The error message
I got on the ia32 client was :

ar: Linux2.i86pc.gnu.dbg/libmpi.a: Input/output error
gmake[4]: *** [Linux2.i86pc.gnu.dbg/libmpi.a] Error 1

and on the ia64 client it was :

ar: Linux2.ia64.gnu.dbg/libmpi.a: Stale NFS file handle
gmake[4]: *** [Linux2.ia64.gnu.dbg/libmpi.a] Error 1

Now, since both these clients got almost the same problem (ok the 2.2.19
client reported -EIO, and the 2.4.18 client -ESTALE), I tried upgrading my
server to a stock 2.4.18 kernel and that actually helped ...

Can you give me any more details to why it helped upgrading my NFS server
to 2.4.18 ?

Regards,
 --
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency



_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
