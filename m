From: "Greg Bradner" <greg.bradner@gmail.com>
Subject: Re: ROOT_NFS 2.6.20.4 kernel crash
Date: Tue, 3 Apr 2007 09:24:55 -0700
Message-ID: <57bc13580704030924y1574018ag4f67ac677206ce89@mail.gmail.com>
References: <57bc13580704030834n615eaf24tc3294e67916debcc@mail.gmail.com>
	<1175616131.6838.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYloU-0007eg-Hf
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:24:54 -0700
Received: from wr-out-0506.google.com ([64.233.184.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYloW-0007S8-Of
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:24:57 -0700
Received: by wr-out-0506.google.com with SMTP id i20so3274548wra
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 09:24:55 -0700 (PDT)
In-Reply-To: <1175616131.6838.21.camel@heimdal.trondhjem.org>
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

On 4/3/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2007-04-03 at 08:34 -0700, Greg Bradner wrote:
> > I have booted into my NFS-Root and am trying to partition a drive.
> > But kernel is crashing while making dev names.
>
> I believe GregKH has queued up the fix for this for the next stable
> release. See
>
> http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=commit;h=634707388baa440d9c9d082cfc4c950500c8952b
>

I checked and that patch is already applied to the 2.6.20.4 kernel.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
