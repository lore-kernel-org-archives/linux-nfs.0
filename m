From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Thu, 21 Oct 2004 22:43:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041022024349.GA30004@fieldses.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com> <1098343891.28394.15.camel@lade.trondhjem.org> <20041021161309.GC24417@fieldses.org> <1098413781.21421.37.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKpPA-0000Vk-Ng
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 19:43:48 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CKpP9-0003Ii-9k
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 19:43:48 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1098413781.21421.37.camel@hole.melbourne.sgi.com>
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

On Fri, Oct 22, 2004 at 12:56:21PM +1000, Greg Banks wrote:
> Yes, and I should have seen that...the attached patch deals
> with nohide by comparing the whole file handle instead of just
> the fileid.

Weird.  But I thought the bug the cthon test was seeing was the result
of the server generating two different filehandles pointing to the same
file?  (And if that isn't the problem, then why was turning on
no_subtree_check also making the test pass?)

--b.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
