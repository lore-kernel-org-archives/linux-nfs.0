From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Sat, 21 Jun 2003 04:22:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16115.20684.513868.459583@gargle.gargle.HOWL>
References: <m3isr2kanm.fsf@merlin.emma.line.org>
	<3EF1CC36.8F3EC825@moving-picture.com>
	<m38yrx3dhx.fsf@merlin.emma.line.org>
	<3EF2D54C.73B9EDAA@moving-picture.com>
	<20030620111408.GC8061@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Pearson <james-p@moving-picture.com>,
    Matthias Andree <ma@dt.e-technik.uni-dortmund.de>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TL3f-0007pX-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 05:32:00 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <matthias.andree@gmx.de>) (for <james-p@moving-picture.com>)
	(for <ma@dt.e-technik.uni-dortmund.de>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 20 Jun 2003 22:31:19 +1000
To: Matthias Andree <matthias.andree@gmx.de>
In-Reply-To: message from Matthias Andree on Friday June 20
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

On Friday June 20, matthias.andree@gmx.de wrote:
> On Fri, 20 Jun 2003, James Pearson wrote:
> > There was a posting from Neil Brown recently about possible changes for
> > 2.6 kernels, that mentions doing away with rmtab - see:
> > 
> > http://marc.theaimsgroup.com/?l=linux-nfs&m=105331510308653&w=2
> 
> nfsd was supposed to be stateless ;-)

(I noticed the smiley, but thought I would reply anyway...)

Nope.   NFS - the protocol - is stateless (Except for the state file
               files stored on the fileserver....)
        MOUNTD and NLM are separate supporting protocols, neither of
               which are stateless.

and "nfsd" is a program, not a protocol.  What does it mean for a
program to be stateless?

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
