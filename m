From: Steffen Persvold <sp@scali.com>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 16:01:32 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0205141600370.28246-100000@sp-home.isdn.scali.no>
References: <Pine.LNX.4.44.0205140618080.21683-100000@glenfiddich.cse.ogi.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177cx7-0004bh-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 07:06:57 -0700
To: Paul Heinlein <heinlein@cse.ogi.edu>
In-Reply-To: <Pine.LNX.4.44.0205140618080.21683-100000@glenfiddich.cse.ogi.edu>
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

On Tue, 14 May 2002, Paul Heinlein wrote:

> On Tue, 14 May 2002, Steffen Persvold wrote:
>
> > The relevant /proc/mounts looks like this :
> >
> > huey:/export/home/sp /home/sp nfs rw,v3,rsize=8192,wsize=8192,intr,addr=huey 0 0
>
> Pardon my asking a question that's likely irrelevant -- but why are
> your {r,w}size settings stuck at 8k? I've never done any transfer-size
> testing under a 2.2.x kernel, but won't it negotiate something closer
> to 32k when running nfs v3?
>

I believe the maximum for NFS messages sizes is still 8k (unless you have
Trond's rpc-twaks.diff).

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
