From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils 1.0.11
Date: Mon, 26 Feb 2007 10:25:04 -0500
Message-ID: <4d569c330702260725g3c69d0e2xbe6206c17439d15d@mail.gmail.com>
References: <17885.10111.791755.714451@notabene.brown>
	<45E2CDB5.7090900@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLhj2-0004R5-7u
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 07:25:18 -0800
Received: from wr-out-0506.google.com ([64.233.184.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLhj3-0005lQ-9V
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 07:25:18 -0800
Received: by wr-out-0506.google.com with SMTP id 68so1616313wri
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 07:25:16 -0800 (PST)
In-Reply-To: <45E2CDB5.7090900@RedHat.com>
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

On 2/26/07, Steve Dickson <SteveD@redhat.com> wrote:
> Hey Neil,
>
> Neil Brown wrote:
> >
> > I have just made a release of  nfs-utils 1.0.11
>
> Unfortunately there are some problems with the
> FS-Location patches you used... namely they don't
> compile... So attached is the patch that takes
> care of the compile problems...
>
> The correction patch came from CITI, with a few tweaks
> of my own... namely turning the syslog calls in
> the mountd code to xlog calls..
>
> The commit blob is relative to:
> git://git.infradead.org/~steved/nfs-utils.git
>
> steved.

Yes, I was waiting to figure out why the fslocations stuff isn't
working, even with this patch, before sending it.  I'll keep
looking...

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
