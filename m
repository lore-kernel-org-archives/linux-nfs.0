From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Fri, 04 Aug 2006 09:27:59 -0400
Message-ID: <1154698079.3378.2.camel@localhost.localdomain>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8zXL-0006Uh-IN
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 06:16:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8zXK-00007Q-PX
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 06:16:24 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1154683665.21040.2431.camel@hole.melbourne.sgi.com>
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

On Fri, 2006-08-04 at 19:27 +1000, Greg Banks wrote:
> On Tue, 2006-08-01 at 11:55, Wendy Cheng wrote:
> > o The nfs-utils config flag RESTRICTED_STATD must be off for NLM
> >   failover to be functional correctly.
> 
> That would reopen this ancient security hole:
> 
> http://www.cert.org/advisories/CA-99-05-statd-automountd.html
> 
> which might not be the best of ideas.
> 

ok, thanks ! I'll look into this. But I believe nfs-utils-1.0.8-rc4 has
this off by default ?

-- Wendy


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
