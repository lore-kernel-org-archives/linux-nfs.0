From: Steffen Persvold <sp@scali.com>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 13:15:16 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205141313470.28229-100000@elin.scali.no>
References: <shselgff1dd.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177aH3-0007fp-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 04:15:21 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shselgff1dd.fsf@charged.uio.no>
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

ioOn 14 May 2002, Trond Myklebust wrote:

> >>>>> " " == Steffen Persvold <sp@scali.com> writes:
>
>      > I'm compiling up a large project which resides on a NFS mounted
>      > ext2 filesystem. In this case the NFS server is running RH 7.2
>      > kernel-smp-2.4.9-21 (i686 version) nfs-utils-0.3.1-13.7.2.1,
>      > and the client is running RH 6.2 kernel-enterprise-2.2.19-6.2.7
>      > (i686 version).
>
> If you want to run a 2.2. client, then grab 2.2.21-rc2, and apply the
> patch from
>
>   http://www.fys.uio.no/~trondmy/src/2.2.21-rc2/linux-2.2.21-NFS.dif
>

Do I have to ? Will it fix my problem ? Other known NFS bugs ?

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
