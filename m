From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 13:06:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098464813.8813.18.camel@lade.trondhjem.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <16760.31766.119716.302669@cse.unsw.edu.au>
	 <1098418326.21421.49.camel@hole.melbourne.sgi.com>
	 <1098448136.21421.78.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, "Dr. Bruce Fields" <bfields@fieldses.org>, Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CL2sl-0001NP-36
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 10:07:15 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CL2sk-00051B-FG
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 10:07:15 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1098448136.21421.78.camel@hole.melbourne.sgi.com>
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

fr den 22.10.2004 Klokka 22:28 (+1000) skreiv Greg Banks:

> Well, that was instructive.  There seem to be several interesting
> problems; the most obvious of which is that the dentry refcount
> accounting in nfs_rename() is off by one, so that the client does
> a sillyrename even when there *no* file descriptors open for the
> target file.  This is actually what happens in the cthon test code
> and I've verified it with a small test case.

Yes. This is correct.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
