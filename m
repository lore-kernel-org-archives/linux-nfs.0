From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd and statd
Date: Wed, 04 Apr 2007 17:34:23 -0400
Message-ID: <1175722463.7279.16.camel@heimdal.trondhjem.org>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<1175690426.6118.6.camel@heimdal.trondhjem.org>
	<57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>
	<200704041933.27315.okir@lst.de>  <4613F34C.2040709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZD7l-0004J1-3A
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 14:34:37 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19lqlqLol2hR0Ms2MRPrBTMDX3Z6PKNNe0=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HZD7l-0002LN-5g
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 14:34:39 -0700
In-Reply-To: <4613F34C.2040709@redhat.com>
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

On Wed, 2007-04-04 at 14:49 -0400, Wendy Cheng wrote:
> Olaf Kirch wrote:
> > On Wednesday 04 April 2007 18:09, Greg Bradner wrote:
> >   
> >> That's what I thought.  But it doesn't seem to be the case with SUSE 9.3:
> >>     
> >
> > Suse uses a patch that puts statd functionality into the kernel.
> > So when you switch to a non-Suse kernel, you also need to compile
> > and install rpc.statd manually - and frob your init scripts so that it gets
> > started.
> >   
> 
> I'm wondering what would be the reason(s) that the community version of 
> Linux statd is put in user space ? Any one cares to give either a 
> technical or historical explanation ?
> 
> -- Wendy

Off the cuff, I can think of 2 main reasons why it needs to be in user
space:
 1) It creates and maintains a directory hierarchy on permanent storage
(as opposed to in a pseudo filesystem).
 2) It needs to resolve addresses via DNS etc.

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
