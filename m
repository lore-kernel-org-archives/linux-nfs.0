From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Thu, 21 Oct 2004 12:13:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041021161309.GC24417@fieldses.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com> <1098343891.28394.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKfYt-0001JV-9m
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 09:13:11 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CKfYr-0006Wi-1T
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 09:13:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1098343891.28394.15.camel@lade.trondhjem.org>
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

On Thu, Oct 21, 2004 at 09:31:31AM +0200, Trond Myklebust wrote:
> to den 21.10.2004 Klokka 16:51 (+1000) skreiv Greg Banks:
> > G'day,
> > 
> > The attached patch forward ports from 2.4 the fix to nfs_rename()
> > which makes the nfsidem test in the Connectathon test suite pass.
> 
> 
> Vetoed.
> 
> This remains a server bug, not a client bug. The default should NOT be
> no_subtree_check.

We could do something like this for v4, though, couldn't we?

(I'm looking at rfc3530 section 9.3, which allows the client to assume
two files are the same if the server returns the same fileid and fsid
attributes for the two filehandles and doesn't return TRUE for
unique_handles on either.)

--b.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
