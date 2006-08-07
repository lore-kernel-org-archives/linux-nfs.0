From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Mon, 07 Aug 2006 14:05:31 +1000
Message-ID: <1154923530.29877.104.camel@hole.melbourne.sgi.com>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
	<1154698079.3378.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9wN1-0006yI-6X
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:05:39 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9wN0-0006dq-G6
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:05:39 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1154698079.3378.2.camel@localhost.localdomain>
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

On Fri, 2006-08-04 at 23:27, Wendy Cheng wrote:
> On Fri, 2006-08-04 at 19:27 +1000, Greg Banks wrote:
> > On Tue, 2006-08-01 at 11:55, Wendy Cheng wrote:
> > > o The nfs-utils config flag RESTRICTED_STATD must be off for NLM
> > >   failover to be functional correctly.
> > 
> > That would reopen this ancient security hole:
> > 
> > http://www.cert.org/advisories/CA-99-05-statd-automountd.html
> > 
> > which might not be the best of ideas.
> > 
> 
> ok, thanks ! I'll look into this. But I believe nfs-utils-1.0.8-rc4 has
> this off by default ?

I really hope distros have --enable-secure-statd in their .specs.

I know SLES9+ doesn't need it, because SLES has Olaf's in-kernel
rpc.statd which (IIRC) has the equivalent of RESTRICTED_STATD
hardcoded.

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
