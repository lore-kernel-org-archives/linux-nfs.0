From: Patrick McHardy <kaber@trash.net>
Subject: Re: nfsd oops in current -git
Date: Fri, 13 Jul 2007 22:24:31 +0200
Message-ID: <4697DF7F.3030400@trash.net>
References: <469780BB.3070206@trash.net> <4697A7EC.6050006@redhat.com>
	<20070713163337.GT5328@kernel.dk> <20070713165001.GV5328@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Chuck Ebbert <cebbert@redhat.com>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9RhB-0000aP-2I
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 13:24:57 -0700
Received: from stinky.trash.net ([213.144.137.162])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9RhD-0001eq-8v
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 13:25:00 -0700
In-Reply-To: <20070713165001.GV5328@kernel.dk>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Jens Axboe wrote:
>>>On 07/13/2007 09:40 AM, Patrick McHardy wrote:
>>>
>>>>I get this oops with current -git:
>>>>
>>>>[ 3437.018923] Pid: 4432, comm: nfsd Not tainted 2.6.22 #5
>>>>[ 3437.018926] RIP: 0010:[<ffffffff81054eff>]  [<ffffffff81054eff>]
>>>>put_page+0x4/0xb3

> Patrick, does this work?


Seems to work fine, thanks Jens.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
