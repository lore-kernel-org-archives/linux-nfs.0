From: Antoine Jacoutot <ajacoutot@lphp.org>
Subject: Re: nfssvc: Permission denied
Date: Tue, 19 Nov 2002 09:40:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200211190940.13341.ajacoutot@lphp.org>
References: <1037370050.3dd502c24af77@webmail.lphp.org> <15833.49764.873851.3047@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from apastourelles-107-1-17-153.abo.wanadoo.fr ([81.48.127.153] helo=mail.lphp.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18E3vx-0003P9-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 00:40:38 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15833.49764.873851.3047@notabene.cse.unsw.edu.au>
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

On Tuesday 19 November 2002 05:47, Neil Brown wrote:
> On Friday November 15, ajacoutot@lphp.org wrote:
> > Hi,
> >
> > I'm using NFS under Gentoo Linux with kernel-2.4.19.
> > When starting nfs server with nfs init script (from nfs-utils), I get=
 the
> > following message:
> >
> > /etc/init.d/nfs start
> > [ok ] * Starting NFS statd...
> > [ ok ] * Starting NFS rquotad...
> > [ ok ] * Starting NFS daemon...
> > nfssvc: Permission denied
>
> It looks like you are not running this as root.  You need to.
>

I am running is as root !
Besides, it works, but after 7 or 8 times restarting the service. This is=
 very=20
strange.



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
