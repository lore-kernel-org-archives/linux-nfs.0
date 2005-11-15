From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: Re: [PATCH kNFSd ] Make sure nfsd doesn't hog a cpu forever.
Date: Tue, 15 Nov 2005 12:33:37 -0200
Message-ID: <17273.61889.607871.762490@fisica.ufpr.br>
References: <20051115125307.9288.patches@notabene>
	<1051115015429.9307@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ec1sX-00023i-ME
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 06:33:45 -0800
Received: from fisica.ufpr.br ([200.17.209.129])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ec1sW-0001gz-Ch
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 06:33:45 -0800
To: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
In-Reply-To: <1051115015429.9307@cse.unsw.edu.au>
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

NeilBrown (neilb@cse.unsw.edu.au) wrote on 15 November 2005 12:54:
 >Against 2.6.14-mm2, or 2.6.15-rc1
 >### Comments for Changeset
 >
 >Being kernel-threads, nfsd servers don't get pre-empted (depending on
 >CONIG).  If there is a steady stream of NFS requests that can be
 >served from cache, an nfsd thread may hold on to a cpu indefinitely ,
 >which isn't very friendly.
 >
 >So it is good to have a cond_resched in there (just before looking for
 >a new request to serve), to make sure we play nice.

Yes!!!

This happens rather frequently here. I tried to put the nfsd threads
at nice 19 but it helped only a little and disturbs the other clients
too...

Could this be done for 2.4 also?


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
