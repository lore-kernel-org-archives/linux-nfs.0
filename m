From: Olaf Kirch <okir@suse.de>
Subject: Re: Proposal: Starting statd on demand
Date: Tue, 13 Apr 2004 10:59:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040413085923.GD15896@suse.de>
References: <20040409180352.GH2767@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BDJmm-0003Hv-Kk
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 02:00:52 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BDJmm-0004eM-68
	for nfs@lists.sourceforge.net; Tue, 13 Apr 2004 02:00:52 -0700
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040409180352.GH2767@perlsupport.com>
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

On Fri, Apr 09, 2004 at 02:03:52PM -0400, Chip Salzenberg wrote:
> It's a well-known security principle that services should not be running
> when they are not needed.
> 
> I would like to make statd follow that principle.
> 
> Does anyone have a suggestion on how?  I don't want to reinvent an
> already-proposed wheel.

You may want to try my kernel statd patch. It implements a minimal
statd that just supports NULL and SM_NOTIFY in kernel, as an additional
RPC program registered on the same port as lockd.

Note that you still need to have some user land support for statd
which sends out the SM_NOTIFY calls on reboot.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
