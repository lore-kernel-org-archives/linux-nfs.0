From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: librpcsecgss conflicts with clnt libc symbols
Date: Tue, 1 Aug 2006 10:55:02 -0400
Message-ID: <4d569c330608010755s21d6bc6bv6a0ec3d8668aa3db@mail.gmail.com>
References: <200607312329.33067.vapier@gentoo.org>
	<4d569c330608010631m70adbb7ft6b60f5c19bde64a5@mail.gmail.com>
	<200608011032.33097.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7veB-0007cj-Qj
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 07:55:03 -0700
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7veB-0000Gv-Va
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 07:55:04 -0700
Received: by nf-out-0910.google.com with SMTP id m19so300623nfc
	for <nfs@lists.sourceforge.net>; Tue, 01 Aug 2006 07:55:02 -0700 (PDT)
To: "Mike Frysinger" <vapier@gentoo.org>
In-Reply-To: <200608011032.33097.vapier@gentoo.org>
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

On 8/1/06, Mike Frysinger <vapier@gentoo.org> wrote:
> On Tuesday 01 August 2006 09:31, Kevin Coffman wrote:
> > They were added in 0.8:
> > > Changes since librpcsecgss-0.7:
> > >
> > > -- From Olga Kornievskaia: add new prep_refresh function to clean up
> > >    context information before trying to refresh a context
> > > -- From Olga Kornievskaia: add new function to access retry count
> > >    for a context.
> > > -- Adds back clnt_ files which have the necessary calls needed for
> > >    privacy.
> >
> > The libc versions of the clnt*_call functions do not call the
> > AUTH_WRAP and AUTH_UNWRAP functions needed for privacy.
>
> ok, so that answers the first question (should they be there) ...
>
> next is, should they be hidden for internal use only ?  or all consumers of
> librpcsecgss supposed to call the clnt_* funcs in there ?
>
> the problem i'm trying to deal with is glibc may call the clnt funcs in some
> auth scenarios and the versions in librpcsecgss are used instead of the ones
> in libc (like when libnsl enters the picture)
>
> i'll prob have to go through this user's bug report and try to reproduce it
> myself ... last time i tried to use nfs4 it just totally didnt work ;)
> -mike

I've seen this with authenticated NIS.  Can you point me at the bug report?

I'm working on a patch right now for librpcsecgss that hides our
versions of these functions by renaming them to rpcsecgss_*.  It may
require some configure changes to the nfs-utils code to make it happy
with the new names...

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
