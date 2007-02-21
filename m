From: Jean-Denis Girard <jd.girard@sysnux.pf>
Subject: Re: Server not working since 2.6.20-rc
Date: Tue, 20 Feb 2007 14:11:04 -1000
Message-ID: <45DB8E18.4050606@sysnux.pf>
References: <45DB8447.1060903@sysnux.pf>
	<4d569c330702201540k641f6a32i204006f7e22a2ebc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJfBD-0000qe-6y
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:17:55 -0800
Received: from smtpq.mana.pf ([202.3.225.153] ident=mirapoint)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJfBD-0001OW-Im
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:17:57 -0800
In-Reply-To: <4d569c330702201540k641f6a32i204006f7e22a2ebc@mail.gmail.com>
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

Kevin Coffman a =E9crit :
> This patch from Bruce worked for me:
> =

> --- a/net/sunrpc/svcsock.c~copy_address_correctly       2007-02-06
> 16:55:30.000000000 -0500
> +++ b/net/sunrpc/svcsock.c      2007-02-12 14:27:59.000000000 -0500
> @@ -1038,7 +1038,7 @@
>        if (!(newsvsk =3D svc_setup_socket(serv, newsock, &err,
>                                 (SVC_SOCK_ANONYMOUS | =

> SVC_SOCK_TEMPORARY))))
>                goto failed;
> -       memcpy(&newsvsk->sk_remote, &sin, slen);
> +       memcpy(&newsvsk->sk_remote, sin, slen);
>        newsvsk->sk_remotelen =3D slen;
> =

>        /* make sure that we don't have too many active connections.

Thanks Kevin for very prompt reply, but I can't find that code in =

net/sunrpc/svcsock.c of the 2.6.20.1 kernel. At line 925 I have:
	if (!(newsvsk =3D svc_setup_socket(serv, newsock, &err, 0)))
		goto failed;


	/* make sure that we don't have too many active connections.


Thanks,
-- =

Jean-Denis Girard

SysNux                  Syst=E8mes Linux en Polyn=E9sie fran=E7aise
http://www.sysnux.pf/   T=E9l: +689 483 527 / GSM: +689 797 527

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
