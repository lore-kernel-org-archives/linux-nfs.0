From: Neil Brown <neilb@suse.de>
Subject: Re: Server not working since 2.6.20-rc
Date: Wed, 21 Feb 2007 11:05:19 +1100
Message-ID: <17883.36031.860122.286061@notabene.brown>
References: <45DB8447.1060903@sysnux.pf>
	<4d569c330702201540k641f6a32i204006f7e22a2ebc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jean-Denis Girard <jd.girard@sysnux.pf>
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJf02-0008Da-KW
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:06:22 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJf03-0002nn-C0
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:06:24 -0800
In-Reply-To: message from Kevin Coffman on Tuesday February 20
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

On Tuesday February 20, kwc@citi.umich.edu wrote:
> 
> This patch from Bruce worked for me:
> 
> --- a/net/sunrpc/svcsock.c~copy_address_correctly       2007-02-06
> 16:55:30.000000000 -0500
> +++ b/net/sunrpc/svcsock.c      2007-02-12 14:27:59.000000000 -0500
> @@ -1038,7 +1038,7 @@
>         if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
>                                  (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
>                 goto failed;
> -       memcpy(&newsvsk->sk_remote, &sin, slen);
> +       memcpy(&newsvsk->sk_remote, sin, slen);
>         newsvsk->sk_remotelen = slen;
> 
>         /* make sure that we don't have too many active connections.
> 

That bug was never in mainline, so I doubt that was it. :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
