From: "james bardin" <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Wed, 24 Jan 2007 19:14:07 -0500
Message-ID: <a3b675320701241614p360a596fjb92723eb5ce6dfd9@mail.gmail.com>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
	<45B73D93.1020508@RedHat.com> <45B7C85C.80105@bu.edu>
	<20070124233908.GS6587@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9sFk-0005Gg-5S
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 16:14:08 -0800
Received: from nz-out-0506.google.com ([64.233.162.239])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9sFk-0001Fz-J6
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 16:14:10 -0800
Received: by nz-out-0506.google.com with SMTP id i11so525734nzi
	for <nfs@lists.sourceforge.net>; Wed, 24 Jan 2007 16:14:08 -0800 (PST)
In-Reply-To: <20070124233908.GS6587@fieldses.org>
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

On 1/24/07, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jan 24, 2007 at 03:58:04PM -0500, James Bardin wrote:
> > Sorry Steve,
> >
> > I accidentally rebooted into kernel 2.6.19 when I tested the patches.
> > Same problem still, and on our 64bit systems, everything fails with
> > statfs error 13.
>
> Just to make sure I understand--the statfs erro on 64bit systems is a
> separate problem from the one described below?
>

statfs error was happening everywhere, but the 64bit systems would fail worse.

> --b.
>
> >
> > Here's the dmesg errors:
> > call_verify: auth check failed
> > call_verify: auth check failed
> > call_verify: auth check failed
> > RPC call_verify: retry failed, exit EIO
> >
> > and:
> > nfs_statfs: statfs error = 13
> >


> Try using the -o noacl mount option...
>
> steved.
>

Steved,
Ok, this seems to be it. ( I'll try out some other configuration/64bit tomorrow)
Could you give me a brief summary on why this is happening, and only
on this kernel? Mostly, should I always be using noacl when the netapp
is handling file access?

thanks
-jim

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
