From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd threads locked, 2.6.7 & ia64
Date: Mon, 28 Jun 2004 11:04:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16607.28296.98868.364827@cse.unsw.edu.au>
References: <20040627051129.GS10560@polop.usc.edu>
	<20040627193314.GE3491@fieldses.org>
	<20040628004602.GU10560@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BekZC-0004TD-5I
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 18:04:14 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BekZB-0007sV-Mz
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 18:04:14 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: message from Garrick Staples on Sunday June 27
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

On Sunday June 27, garrick@usc.edu wrote:
> On Sun, Jun 27, 2004 at 03:33:14PM -0400, J. Bruce Fields alleged:
> > 
> > Does Sysrq-T give you any idea where they're stuck?
> 
> I won't know until I get into the machine room tomorrow.  Any info I can give
> you from a remote shell?
> 

# echo t > /proc/sysrq-trigger
# dmesg

NeilBrown

> -- 
> Garrick Staples, Linux/HPCC Administrator
> University of Southern California


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
