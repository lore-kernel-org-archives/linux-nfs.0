From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Fri, 27 Aug 2004 09:30:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827073049.GA23324@suse.de>
References: <4124DB86.9060505@steeleye.com> <16677.22269.988036.787320@cse.unsw.edu.au> <412E1C10.5020703@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0bHs-0001IO-ED
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 00:36:40 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0bHq-0000Z4-WE
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 00:36:40 -0700
To: Paul Clements <paul.clements@steeleye.com>
In-Reply-To: <412E1C10.5020703@steeleye.com>
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

Hi,

I'm working on putting statd into the kernel, so I'm necessarily not
too enthusiastic about adding external callouts to statd :)

On Thu, Aug 26, 2004 at 01:21:20PM -0400, Paul Clements wrote:
> statd events that trigger a callout:
> -----------------------------------
> add client to notify list (SM_MON) - triggers "add-client" callout
> 
> delete client from notify list (SM_UNMON and SM_UNMONALL) - triggers 
> "del-client" callout

I think the same could be achieved by attaching a dnotify handler to
the directory, and it would be compatible with a kernel level statd.

Cheers
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
