From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ROOT_NFS 2.6.20.4 kernel crash
Date: Tue, 03 Apr 2007 12:16:44 -0400
Message-ID: <1175617004.6838.23.camel@heimdal.trondhjem.org>
References: <57bc13580704030834n615eaf24tc3294e67916debcc@mail.gmail.com>
	<1175616131.6838.21.camel@heimdal.trondhjem.org>
	<57bc13580704030908m3cc899b6hfe169e9ed7176a67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Greg Bradner <greg.bradner@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYlgl-0006MP-Gg
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:16:55 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+PTYCsb2YSwcTRqzkWtGIO3wBVujAesJY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HYlgm-0003TF-Bd
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:16:57 -0700
In-Reply-To: <57bc13580704030908m3cc899b6hfe169e9ed7176a67@mail.gmail.com>
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

On Tue, 2007-04-03 at 09:08 -0700, Greg Bradner wrote:
> On 4/3/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2007-04-03 at 08:34 -0700, Greg Bradner wrote:
> > > I have booted into my NFS-Root and am trying to partition a drive.
> > > But kernel is crashing while making dev names.
> >
> > I believe GregKH has queued up the fix for this for the next stable
> > release. See
> >
> > http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=commit;h=634707388baa440d9c9d082cfc4c950500c8952b
> >
> 
> I have to ask, but what do I do in the meantime?
> Thanks

Apply the patch from the above link? ;-)

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
