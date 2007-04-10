From: Olaf Kirch <okir@lst.de>
Subject: Re: [PATCH 2/4 Revised] NLM - set per fsid grace period
Date: Tue, 10 Apr 2007 10:57:22 +0200
Message-ID: <200704101057.24105.okir@lst.de>
References: <46156F81.8010808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbCAV-0007xE-7n
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 01:57:40 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HbCAV-0003L7-95
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 01:57:41 -0700
In-Reply-To: <46156F81.8010808@redhat.com>
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

On Thursday 05 April 2007 23:52, Wendy Cheng wrote:
> This change enables per NFS-export entry lockd grace period. The 
> implementation is based on a double linked list fo_fsid_list that 
> contains entries of fsid info. It is expected this would not be a 
> frequent event. The fo_fsid_list is short and the entries expire within 
> a maximum of 50 seconds.  The grace period setting follows the existing 
> NLM grace period handling logic and is triggered via echoing the NFS 
> export filesystem id into nfsd procfs entry as:

Your patch creates a new per-export structure that is private to lockd.
It may be easier to put the grace period value into the export entry,
and check for that in nlm_fopen. It feels more natural than adding
a whole new shadow export table just for the benefit of lockd.
(Especially when you consider future extensions like being able
to search the list by dev_t or uuid or whatever)

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
