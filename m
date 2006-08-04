From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Fri, 04 Aug 2006 10:56:02 -0400
Message-ID: <1154703362.3378.45.camel@localhost.localdomain>
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
	id 1G90uf-0005gP-V5
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 07:44:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G90ud-00018t-7C
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 07:44:34 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
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

On Fri, 2006-08-04 at 09:27 -0400, Wendy Cheng wrote:
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
> 

Anyway, better be conservative than sorry - I think we want to switch to
"fsid" approach to avoid messing with these networking issues, including
IPV6 modification. That is, we use fsid as the key to drop the lock and
set per-fsid NLM grace period. The ha-callout will have a 4th argument
(fsid) when invoked. 

-- Wendy




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
