From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: librpcsecgss conflicts with clnt libc symbols
Date: Tue, 1 Aug 2006 09:31:39 -0400
Message-ID: <4d569c330608010631m70adbb7ft6b60f5c19bde64a5@mail.gmail.com>
References: <200607312329.33067.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7uLW-0008M2-DA
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 06:31:42 -0700
Received: from wr-out-0506.google.com ([64.233.184.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7uLV-0000KZ-Lb
	for nfs@lists.sourceforge.net; Tue, 01 Aug 2006 06:31:42 -0700
Received: by wr-out-0506.google.com with SMTP id 69so394052wri
	for <nfs@lists.sourceforge.net>; Tue, 01 Aug 2006 06:31:40 -0700 (PDT)
To: "Mike Frysinger" <vapier@gentoo.org>
In-Reply-To: <200607312329.33067.vapier@gentoo.org>
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

They were added in 0.8:

> Changes since librpcsecgss-0.7:

> -- From Olga Kornievskaia: add new prep_refresh function to clean up
>    context information before trying to refresh a context
> -- From Olga Kornievskaia: add new function to access retry count
>    for a context.
> -- Adds back clnt_ files which have the necessary calls needed for
>    privacy.

The libc versions of the clnt*_call functions do not call the
AUTH_WRAP and AUTH_UNWRAP functions needed for privacy.


On 7/31/06, Mike Frysinger <vapier@gentoo.org> wrote:
> the librpcsecgss duplicates some functions that the system libc normally
> provides ... in this case:
> clnt_create
> clnt_pcreateerror
> clnt_perrno
> clnt_perror
> clntraw_create
> clnt_spcreateerror
> clnt_sperrno
> clnt_sperror
> clnttcp_create
> clntudp_bufcreate
> clntudp_create
>
> is there a reason for this ?  i went through the ChangeLog and couldnt find
> anything ... this stuff was added like between 0.7 and 0.8 but there doesnt
> appear to be any mention of why ...
> -mike
>
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys -- and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
