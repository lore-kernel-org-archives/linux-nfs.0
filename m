From: trond.myklebust@fys.uio.no
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 13:49:45 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32895.207.214.87.84.1077799785.squirrel@webmail.uio.no>
References: <20040225022210.51884.qmail@web12821.mail.yahoo.com>
    <403D692D.33C4D7E8@melbourne.sgi.com>
    <20040226084146.GA1197@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Greg Banks" <gnb@melbourne.sgi.com>,
     "Shantanu Goel" <sgoel01@yahoo.com>,nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKzV-0003PJ-3Y
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:51:49 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKju-00010k-BS
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:35:42 -0800
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040226084146.GA1197@suse.de>
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

På to , 26/02/2004 klokka 00:41, skreiv Olaf Kirch:
> What about modifying __rpc_sleep_on to put sync tasks always
> at the head of the queue? This way sync tasks get priority when
> it comes to call reservation.

How do you avoid the inverse problem that async tasks end up never making
any progress? I'm not a huge fan of playing with rpc task
priorities: just witness the type of tuning problems Ingo & co. had (and
still have IMO) when they played around with the task scheduler
algorithm for 2.6.x.

I think I prefer an approach like that taken by Shantanu, however there
are 2 problems with his code as it stands today:

  - It only addresses the problem of writes (yes, we sometimes do read a
bit too).
  - It is a fairly heavy layering violation. It would be nice to move
some (all?) of that code into the RPC layer if possible.

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
