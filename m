From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NLM GRANT callback using AUTH_NULL is rejected
Date: Thu, 17 Nov 2005 11:05:08 -0500
Message-ID: <20051117160508.GB2337@fieldses.org>
References: <044B81DE141D7443BCE91E8F44B3C1E2013327B6@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcmGG-0005t4-SE
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:05:20 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcmGC-0004Ka-84
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 08:05:20 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E2013327B6@exsvl02.hq.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Thu, Nov 17, 2005 at 07:38:22AM -0800, Lever, Charles wrote:
> our filer sends NLM GRANTED callbacks back to clients using AUTH_NULL
> authentication.  Linux clients always seem to reject these callbacks.
> 
> parsing through fs/lockd and net/sunrpc, i see a comment that indicates
> that AUTH_NULL RPC requests are subject to IP access control (a la
> /etc/exports).  theoretically, if lockd doesn't register the filer in
> the ip_map cache, then all the filer's callbacks will be rejected,
> right?

See

http://marc.theaimsgroup.com/?l=linux-nfs&m=110608174305835&w=2

and following messages.  These appear to have gone into 2.6 in early
March sometime, so I assume that was about 2.6.12?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
