From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd threads locked, 2.6.7 & ia64
Date: Sun, 27 Jun 2004 15:33:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040627193314.GE3491@fieldses.org>
References: <20040627051129.GS10560@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BefOu-0007X9-Vh
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 12:33:16 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BefOu-0000Sx-HJ
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 12:33:16 -0700
Received: from bfields by pickle.fieldses.org with local (Exim 4.34)
	id 1BefOs-00019h-3g
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 15:33:14 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040627051129.GS10560@polop.usc.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sat, Jun 26, 2004 at 10:11:29PM -0700, Garrick Staples wrote:
> Well here's something I've not seen yet.  All 512 nfsd threads are stuck in IO
> wait (state D in ps).  All clients are hung on that mount.  The actual
> filesystem on the server seems fine.
> 
> It start at 8am with no messages at all.
> 
> Jun 26 08:06:58 hpc-master nagios: SERVICE ALERT: hpc-fs3;nfs;CRITICAL;SOFT;1;CRITICAL: RPC program nfs  version 3 udp is not running
> Jun 26 08:07:21 hpc934-e0 kernel: nfs: server hpc-fs3 not responding, still trying
> Jun 26 08:09:12 hpc972-e0 kernel: nfs: server hpc-fs3 not responding, still trying
> Jun 26 08:09:13 hpc941-e0 kernel: nfs: server hpc-fs3 not responding, still trying
> ...
> 
> I can't find anything otherwise wrong with the machine at all, just that nfsd
> threads are stuck.  rpcinfo and showmount still work fine.  Nothing in dmesg or
> messages.  I'm stuck too.

Does Sysrq-T give you any idea where they're stuck?

--Bruce Fields


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
