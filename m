From: Eric Whiting <ewhiting@amis.com>
Subject: Re: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Tue, 01 Jun 2004 10:22:55 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40BCAD5F.4DE90B76@amis.com>
References: <20040528042007.GA9014@sgi.com> <16566.51874.43089.537506@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVCDx-0001sB-8c
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 09:34:49 -0700
Received: from p01m169.mxlogic.net ([66.179.109.169])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BVCDw-0008Ry-PS
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 09:34:48 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:
>
> I have two concerns, that can possibly be allayed.
> 
> Firstly, the reply to any request is going to go out the socket that
> the request came in on.  However some network configurations can have
> requests arrive on one interface that need to be replied to on a
> different interface(*).  

Neil,

Some misc data: It is my understanding that 'networkappliance data ontap' is
wired up to send replies out the same interface the request came in on. This
solves some problems of managing systems connected via multiple network paths. 
I realize it might also create other problems..

eric


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
