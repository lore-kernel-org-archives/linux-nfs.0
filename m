From: "Peter Lojkin" <ia6432@inbox.ru>
Subject: Re: NFS oopses on smp servers
Date: Thu, 26 Dec 2002 17:31:36 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18RZ2u-000GF6-00@f17.mail.ru>
References: <shs8yypaojt.fsf@charged.uio.no>
Reply-To: "Peter Lojkin" <ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Bernhard Kaindl" <bk@suse.de>,
	nfs@lists.sourceforge.net,
	"Chris Mason" <mason@suse.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx9.mail.ru ([194.67.57.19])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18RZ35-0008Fk-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Dec 2002 06:31:47 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <shs8yypaojt.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

we were unable to trigger the oops with this patch so we start installing it on failing servers. none of the updated servers
failed with such oops (first server updated 8 days ago), so i
guess this patch solves the problem. big thanks to all involved
for quick help!

now we have another nfs related oopses. these oopses happend on
both updated and not updated servers, so this patch wasn't the
cause. see my next message to the list for full info...

-----Original Message-----
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 16 Dec 2002 17:58:30 +0100
Subject: Re: [NFS] NFS oopses on smp servers

> >>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
>      > Try the appended patch instead:
> 
> Duh: typo...
> 
> Cheers,
>   Trond
[patch skipped]



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
