From: Steffen Persvold <sp@scali.com>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 13:12:06 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205141308300.28229-100000@elin.scali.no>
References: <shsit5rf1g1.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177aDz-0007P1-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 04:12:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsit5rf1g1.fsf@charged.uio.no>
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

On 14 May 2002, Trond Myklebust wrote:

> >>>>> " " == Steffen Persvold <sp@scali.com> writes:
>
>      > The error I get here is :
>
>      > #     Creating static library Linux2.ia64.gnu/libmpi.a ...
>      > #     Creating shared library Linux2.ia64.gnu/libmpi.so ...
>      > /usr/bin/ld: final link failed: Stale NFS file handle collect2:
>      > ld returned 1 exit status make[4]: ***
>      > [Linux2.ia64.gnu/libmpi.a] Error 1
>
>
> Stale file handle has nothing to do with EIO. That looks more like a
> server bug. Are you perchance using nfs-server?

No, I'm using a standard RH 7.2 server with knfsd
(and nfs-utils-0.3.1-13.7.2.1). rpc.nfsd is started with 48 servers.

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
