From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: how to force umount when "Device or resource busy"?
Date: Wed, 15 Sep 2004 11:14:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095210892.3620.347.camel@hole.melbourne.sgi.com>
References: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7OFx-00086v-Vl
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 18:06:45 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C7OFv-0000Je-Ly
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 18:06:44 -0700
To: ms419@freezone.co.uk
In-Reply-To: <AB813470-0682-11D9-9080-000A95C71776@freezone.co.uk>
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

On Wed, 2004-09-15 at 05:17, ms419@freezone.co.uk wrote:
> How does one unmount when umount doesn't work?
> 
> Somehow, I got an NFS / AutoFS mount that just won't unmount.
> 

See the manpage description of the "-l" flag to umount.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
