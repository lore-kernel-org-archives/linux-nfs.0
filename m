From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Re: [PATCH] nfs-utils - rpc.idmapd - nfsdreopen still broken
Date: Thu, 3 Nov 2005 10:06:52 -0500
Message-ID: <4d569c330511030706r5dfd40eam511e25a32dbf9ee9@mail.gmail.com>
References: <435FE08F.50204@RedHat.com>
	 <17257.41271.14863.770404@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXgg3-0004v0-Dj
	for nfs@lists.sourceforge.net; Thu, 03 Nov 2005 07:06:55 -0800
Received: from zproxy.gmail.com ([64.233.162.204])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EXgg2-0001QN-5N
	for nfs@lists.sourceforge.net; Thu, 03 Nov 2005 07:06:55 -0800
Received: by zproxy.gmail.com with SMTP id z3so187043nzf
        for <nfs@lists.sourceforge.net>; Thu, 03 Nov 2005 07:06:52 -0800 (PST)
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17257.41271.14863.770404@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I have a patch (coming real soon now) that deals with err[x] and
warn[x].  The problem is that these messages go nowhere after the call
to mydaemon(), so errors and warnings are never seen anywhere.  I'll
make sure my patch applies to this new cvs version.

On 11/3/05, Neil Brown <neilb@suse.de> wrote:
> On Wednesday October 26, SteveD@redhat.com wrote:
> > I figured since there is no way of changing these paths or filenames
> > by command line args, why not just set them during compile time...
> > so that's what this patch does.
>
>
> Looks good, except that there seems to be some disagreement about
> idmap_warnx vs warnx, making the patch not apply cleanly for me,
> and the fact that nfsdopenone how has two unused arguments.
>
> I've fixed both of those and committed the change to CVS.
>
> Thanks,
>
> NeilBrown
>
>
> -------------------------------------------------------
> SF.Net email is sponsored by:
> Tame your development challenges with Apache's Geronimo App Server. Downl=
oad
> it for free - -and be entered to win a 42" plasma tv or your very own
> Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
