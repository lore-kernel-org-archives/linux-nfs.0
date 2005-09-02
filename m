From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rquota overflow fix never applied ?
Date: Fri, 2 Sep 2005 16:42:46 +1000
Message-ID: <17175.62566.457851.278132@cse.unsw.edu.au>
References: <200508300108.52636.vapier@gentoo.org>
	<17171.63513.738531.932794@cse.unsw.edu.au>
	<1125417920.8443.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EB5GO-0007tg-Qc
	for nfs@lists.sourceforge.net; Thu, 01 Sep 2005 23:43:00 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EB5GL-0006R2-UE
	for nfs@lists.sourceforge.net; Thu, 01 Sep 2005 23:43:00 -0700
Received: From
	neil.brown.name ([129.94.175.2] == uservpn.cse.unsw.EDU.AU) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 2 Sep 2005 16:42:47 +1000
To: nfs@lists.sourceforge.net
In-Reply-To: message from Trond Myklebust on Tuesday August 30
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


(drat ... sent this with the wrong 'from' address first time and
as nfs-utils is a closed list (grumble grumble) it bounced...
)

On Tuesday August 30, trond.myklebust@fys.uio.no wrote:
> ty den 30.08.2005 Klokka 16:09 (+1000) skreiv Neil Brown:
> 
> > However I seem to be a bit thick today and cannot see where the
> > overflow is happening.
> > dqblk is 6 u_int32_t's and 2 time_t's
> 
> Isn't time_t defined to be unsigned long?
> 
> > struct rquota (after rq_bhardlimit) is 8 u_int's
> 
> Whether or not it fixes the particular problem it claims to, this is a
> patch we should apply (or we should write something similar).

True, and I have now committed it to CVS.
It's just that I like to make sure that I understand a problem
completely before 'fixing' it - it is very easy to miss little details
(though I cannot see any room for hidden details here).

NeilBrown


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
