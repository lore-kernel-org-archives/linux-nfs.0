From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfssvc: Permission denied
Date: Wed, 20 Nov 2002 09:23:38 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15834.47594.326682.768213@notabene.cse.unsw.edu.au>
References: <1037370050.3dd502c24af77@webmail.lphp.org>
	<15833.49764.873851.3047@notabene.cse.unsw.edu.au>
	<200211190940.13341.ajacoutot@lphp.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18EGmZ-000791-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 14:23:48 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <ajacoutot@lphp.org>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 20 Nov 2002 09:23:39 +1100
To: Antoine Jacoutot <ajacoutot@lphp.org>
In-Reply-To: message from Antoine Jacoutot on Tuesday November 19
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

On Tuesday November 19, ajacoutot@lphp.org wrote:
> On Tuesday 19 November 2002 05:47, Neil Brown wrote:
> > On Friday November 15, ajacoutot@lphp.org wrote:
> > > Hi,
> > >
> > > I'm using NFS under Gentoo Linux with kernel-2.4.19.
> > > When starting nfs server with nfs init script (from nfs-utils), I get the
> > > following message:
> > >
> > > /etc/init.d/nfs start
> > > [ok ] * Starting NFS statd...
> > > [ ok ] * Starting NFS rquotad...
> > > [ ok ] * Starting NFS daemon...
> > > nfssvc: Permission denied
> >
> > It looks like you are not running this as root.  You need to.
> >
> 
> I am running is as root !
> Besides, it works, but after 7 or 8 times restarting the service. This is very 
> strange.

Strange indeed.
The only time that nfsd should give this message is 
  	if (!capable(CAP_SYS_ADMIN)) {

Maybe if you
  sh -x /etc/init.d/nfs start

and double check which program is producing the error, and then
   strace ....
that program.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
