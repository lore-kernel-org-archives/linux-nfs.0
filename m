From: Steffen Persvold <sp@scali.com>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 12:42:16 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205141239190.28229-100000@elin.scali.no>
References: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Zl6-00052R-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 03:42:20 -0700
Received: from localhost (sp@localhost)
	by elin.scali.no (8.12.3/8.12.3) with ESMTP id g4EAgGBf028664
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 12:42:16 +0200
To: NFS mailinglist <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
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

On Tue, 14 May 2002, Steffen Persvold wrote:

> Hi all,
>
> I guess I've reported this before, but here we go again:
>
> I'm compiling up a large project which resides on a NFS mounted
> ext2 filesystem. In this case the NFS server is running RH 7.2
> kernel-smp-2.4.9-21 (i686 version) nfs-utils-0.3.1-13.7.2.1, and the
> client is running RH 6.2 kernel-enterprise-2.2.19-6.2.7 (i686 version).
>
> The relevant /proc/mounts looks like this :
>
> huey:/export/home/sp /home/sp nfs rw,v3,rsize=8192,wsize=8192,intr,addr=huey 0 0
>
>
> What happens is that when all object files are compiled (this goes fine),
> a static library is about to be created. This is when the client aborts :
>
> #     Creating static library Linux2.i86pc.gnu/libmpi.a ...
> ar: Linux2.i86pc.gnu/libmpi.a: Input/output error
> make[4]: *** [Linux2.i86pc.gnu/libmpi.a] Error 1
>
> If I try once more (just creating the static library) everything goes
> fine. Another thing is that this is unfortunately not always reproducible.
>
> Is there a know bug in some of my componets which could result in such an
> error ? I would very much appreciate some pointers to what could be wrong
> (not just 'upgrade to latest version, maybe it is fixed').
>


I have also sort of the same problem on another architecture (IA64).
This machine runs a stock 2.4.18 kernel (with ia64 patchset). The filesystem is
also mounted differently (noac):

huey:/export/home/sp /home/sp nfs rw,sync,v3,rsize=8192,wsize=8192,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,udp,noac,lock,addr=huey 0 0

The error I get here is :

#     Creating static library Linux2.ia64.gnu/libmpi.a ...
#     Creating shared library Linux2.ia64.gnu/libmpi.so ...
/usr/bin/ld: final link failed: Stale NFS file handle
collect2: ld returned 1 exit status
make[4]: *** [Linux2.ia64.gnu/libmpi.a] Error 1


Do you think the two different errors are related ?

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
