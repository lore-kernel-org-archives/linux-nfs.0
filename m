From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] fix nfsidem cthon test
Date: Thu, 21 Oct 2004 17:51:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098345111.21421.9.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKXS3-0005dP-59
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 00:33:35 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKXS2-000524-Hh
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 00:33:34 -0700
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

On Thu, 2004-10-21 at 17:31, Trond Myklebust wrote:
> to den 21.10.2004 Klokka 16:51 (+1000) skreiv Greg Banks:
> > G'day,
> > 
> > The attached patch forward ports from 2.4 the fix to nfs_rename()
> > which makes the nfsidem test in the Connectathon test suite pass.
> 
> 
> Vetoed.

I don't get it.  Why is this patch in 2.4?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
