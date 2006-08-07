From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Mon, 07 Aug 2006 00:02:17 -0400
Message-ID: <1154923337.5677.42.camel@localhost>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
	<1154705797.4727.18.camel@localhost> <20060804175232.GA29852@suse.de>
	<1154715807.4727.30.camel@localhost>  <44D39D18.7080907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9wK6-0006gq-Op
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:02:39 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9wK5-0008Eu-TH
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:02:39 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44D39D18.7080907@redhat.com>
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

On Fri, 2006-08-04 at 15:16 -0400, Peter Staubach wrote:
> > Sucks, sucks, sucks....
> 
> Actually, the Solaris implementation matches the intended semantics as
> described in RFC1813.  The number of bytes of requested information
> via readdir(3) is passed via dircount and then the maximum size of the
> response is passed through maxcount.
> 
> The two fields were intended to be used to reduce the overhead on
> the server by passing a hint for the amount of data that the client
> was actually looking for and then a count for the maximum sized response
> that it was prepared to handle.

Right. At first glance a good idea, but in practice it sucks because the
client has no idea of how much data it was looking for. In order to
know, it would need to know the length of the filenames in the
directory. Unless it is already caching the directory, that will be 100%
guesswork.

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
