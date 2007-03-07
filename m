From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 09:09:07 +1100
Message-ID: <17903.14339.553627.431965@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<20070307202949.GH26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4K3-0003Qs-PX
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:09:23 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP4K4-0003n3-HZ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:09:25 -0800
In-Reply-To: message from J. Bruce Fields on Wednesday March 7
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday March 7, bfields@fieldses.org wrote:
> 
> 	- the filehandle->export mapping that this function tells the
> 	  kernel about is cached by nfsd for a half-hour.  That time is
> 	  set a little later in nfsd_fh:
> 
> 	          qword_printint(f, time(0)+30*60);
> 
> 	  I don't think there would be any harm to just changing that
> 	  time(0)+30*60 to 0x7FFFFFFF (== never expire)--nfs-utils
> 	  should be invalidating that cache explicitly whenever it's
> 	  needed.  Maybe that should be the default.

I picked 30 minutes because it seems like a good number at the time
and there where plenty of other more important things to think about.
On reflection, I agree that never-expire is appropriate for the
fsid->exportpoint cache (which is relevant here) and the
client+exportpoint -> export options cache.
The IP->clientname cache should have an expiry time based on the TTL
from the DNS (assuming that the DNS was used to do part of the
mapping), but that information is not available at all easily... so
30minutes is probably as good as anything else.

Patches welcome.... :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
