From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Wed, 16 Oct 2002 22:28:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021016222854.C27038@redhat.com>
References: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Daniel Phillips <phillips@arcor.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1820PF-0002vi-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 19:29:01 -0700
To: Eff Norwood <enorwood@effrem.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>; from enorwood@effrem.com on Mon, Oct 14, 2002 at 01:21:15PM -0700
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

What NIC are you using?  High numbers of interrupts per second are not 
necessarily the problem, but reducing it may be possible.  Diagnosing 
these kinds of performance issues is near impossible without a complete 
description of the system, and the identity of the NIC/driver is 
essential.

		-ben
-- 
"Do you seek knowledge in time travel?"


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
