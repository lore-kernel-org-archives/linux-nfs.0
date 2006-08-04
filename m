From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Fri, 04 Aug 2006 11:51:48 -0400
Message-ID: <1154706709.4727.21.camel@localhost>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
	<1154698079.3378.2.camel@localhost.localdomain>
	<1154703362.3378.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G91y7-00058V-DE
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:52:11 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G91y7-0006uL-LH
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:52:12 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1154703362.3378.45.camel@localhost.localdomain>
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

On Fri, 2006-08-04 at 10:56 -0400, Wendy Cheng wrote:
> Anyway, better be conservative than sorry - I think we want to switch to
> "fsid" approach to avoid messing with these networking issues, including
> IPV6 modification. That is, we use fsid as the key to drop the lock and
> set per-fsid NLM grace period. The ha-callout will have a 4th argument
> (fsid) when invoked. 

What is the point of doing that? As far as the client is concerned, a
server has either rebooted or it hasn't. It doesn't know about single
filesystems rebooting.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
