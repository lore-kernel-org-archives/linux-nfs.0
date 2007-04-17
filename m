From: Olaf Kirch <okir@lst.de>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 17 Apr 2007 16:51:35 +0200
Message-ID: <200704171651.36497.okir@lst.de>
References: <46156FA0.4030506@redhat.com> <200704171352.27620.okir@lst.de>
	<4624CA93.4040307@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	Lon Hohberger <lhh@redhat.com>, nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdp23-0003dE-Pf
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 07:51:47 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Hdp24-0004Mt-ST
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 07:51:50 -0700
In-Reply-To: <4624CA93.4040307@redhat.com>
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

On Tuesday 17 April 2007 15:24, Wendy Cheng wrote:
> > I think in term of correctness, it's better to send an SM_NOTIFY
> > for each IP associated with such a set, anyway.
> >   
> 
> That's exactly what we have been proposing... :) .. We'll rely heavily 
> on HA callout program to tell us which client uses which (server) 
> floating IP. 

Correct me if I'm wrong, but it seems your patch records every IP
used by the client, rather than the *all* the IPs related to the set of
file systems being moved. So if there are several IPs for this set, you
will end up sending notifications only from those the client happened
to have talked to.

My point was, you move a set of file systems A, B and C, with
IPs X, Y, Z. You know what the addresses are, so from a
robustness point of view your best bet is to send SM_NOTIFY
messages from IPs X, Y, Z, regardless of whether the client has
been talking to all of them, or just one.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
