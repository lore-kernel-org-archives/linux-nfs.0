From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [Fwd: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.]
Date: Mon, 19 Mar 2007 11:08:29 -0400
Message-ID: <1174316909.6461.17.camel@heimdal.trondhjem.org>
References: <45FAB960.5060002@RedHat.com>
	<17917.52907.759968.967401@notabene.brown>
	<45FE8A86.9050307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTJU0-0002Ci-PW
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 08:09:12 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTJU1-00074g-Rb
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 08:09:15 -0700
In-Reply-To: <45FE8A86.9050307@RedHat.com>
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

On Mon, 2007-03-19 at 09:05 -0400, Steve Dickson wrote:
> 
> Neil Brown wrote:
> > On Friday March 16, SteveD@redhat.com wrote:
> >> Any status or hope with these patches??
> > 
> > I have no problem with the nfs-utils patch though obviously I won't
> > commit it until Trond indicates that he will accept the fs/nfs patch. 
> Sounds reasonable...
> 
> Trond, any interest in the 4 line patch that would
> enable turning off readdirplus? The Tru64 folks would
> definitely appreciate it.. ;-)

Fine by me, but I'm curious as to why you're not doing the same for
NFSv4? If we're to support automatic negotiation of the NFS version some
day, then we do need to have all NFSv3 options supported in NFSv4 and
vice versa.

Cheers
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
