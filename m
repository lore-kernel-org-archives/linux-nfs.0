From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fix rpc.gssd -d
Date: Mon, 5 Feb 2007 09:53:59 +1100
Message-ID: <17862.25607.109790.62992@notabene.brown>
References: <20070104194625.GA3000@uio.no>
	<4d569c330701041254m5a1fc1aem17a9eaadcbeaadfb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDqFk-00014x-Nb
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:54:34 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDqFj-0006oi-TN
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:54:34 -0800
In-Reply-To: message from Kevin Coffman on Thursday January 4
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

On Thursday January 4, kwc@citi.umich.edu wrote:
> Thanks Steinar.  I'll get to this and the AM_MAINTAINER_MODE patch
> soon and resend them to Neil.  (Your other recent patches are out of
> my arena.)

I've applied this patch as it is trivially correct.
Thanks.
NeilBrown

> 
> K.C.
> 
> On 1/4/07, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> > Fix an off-by-one in the handling of the -d option to rpc.gssd; this makes
> > the option usable again (it would complain that the string was too long).
> > This patch is originally by Liam Bedford, and extracted from
> >
> >   https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/76409
> >
> > --- nfs-utils-1.0.10.orig/utils/gssd/gssd.c
> > +++ nfs-utils-1.0.10/utils/gssd/gssd.c
> > @@ -118,7 +118,7 @@ main(int argc, char *argv[])
> >                                 break;
> >                         case 'd':
> >                                 strncpy(ccachedir, optarg, sizeof(ccachedir));
> > -                               if (ccachedir[sizeof(ccachedir-1)] != '\0')
> > +                               if (ccachedir[sizeof(ccachedir)-1] != '\0')
> >                                         errx(1, "ccachedir path name too long");
> >                                 break;
> >                         default:
> >
> > /* Steinar */
> > --
> > Homepage: http://www.sesse.net/
> >
> > -------------------------------------------------------------------------
> > Take Surveys. Earn Cash. Influence the Future of IT
> > Join SourceForge.net's Techsay panel and you'll get the chance to share your
> > opinions on IT & business topics through brief surveys - and earn cash
> > http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
