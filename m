From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Fri, 04 Aug 2006 19:27:46 +1000
Message-ID: <1154683665.21040.2431.camel@hole.melbourne.sgi.com>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8vyG-0004NO-Aq
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 02:27:56 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8vyE-0007to-Lf
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 02:27:56 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1154397341.3378.10.camel@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2006-08-01 at 11:55, Wendy Cheng wrote:
> o The nfs-utils config flag RESTRICTED_STATD must be off for NLM
>   failover to be functional correctly.

That would reopen this ancient security hole:

http://www.cert.org/advisories/CA-99-05-statd-automountd.html

which might not be the best of ideas.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
