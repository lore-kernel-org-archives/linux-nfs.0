From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd stops functioning
Date: Thu, 5 Aug 2004 10:46:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040805144659.GD25948@fieldses.org>
References: <411217BE.8070209@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsjWJ-0004la-8P
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 07:47:03 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BsjWI-0000vw-RN
	for nfs@lists.sourceforge.net; Thu, 05 Aug 2004 07:47:03 -0700
To: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
In-Reply-To: <411217BE.8070209@framestore-cfc.com>
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

On Thu, Aug 05, 2004 at 12:19:26PM +0100, Johan van den Dorpe wrote:
> For a long time we've been experiencing problems with rpc.mountd 
> stopping functioning.

Maybe you need the following?

(Neil or someone, could you please apply this?  Last I checked it wasn't
in nfs-utils cvs.)

--Bruce Fields

>From Garrick Staples <garrick@usc.edu>:

After mountd handles a cache upcall, we should clear the relevant bits in the
fd_set.

---

 nfs-utils-1.0.6-bfields/utils/mountd/cache.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN utils/mountd/cache.c~cache_select_bugfix utils/mountd/cache.c
--- nfs-utils-1.0.6/utils/mountd/cache.c~cache_select_bugfix	2004-07-14 12:52:57.000000000 -0400
+++ nfs-utils-1.0.6-bfields/utils/mountd/cache.c	2004-07-14 12:52:57.000000000 -0400
@@ -315,6 +315,7 @@ int cache_process_req(fd_set *readfds) 
 		    FD_ISSET(fileno(cachelist[i].f), readfds)) {
 			cnt++;
 			cachelist[i].cache_handle(cachelist[i].f);
+			FD_CLR(fileno(cachelist[i].f), readfds);
 		}
 	}
 	return cnt;
_


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
