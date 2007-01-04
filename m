From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH] fix rpc.gssd -d
Date: Thu, 4 Jan 2007 15:54:05 -0500
Message-ID: <4d569c330701041254m5a1fc1aem17a9eaadcbeaadfb@mail.gmail.com>
References: <20070104194625.GA3000@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2ZbE-0003Lg-Sj
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 12:54:09 -0800
Received: from ug-out-1314.google.com ([66.249.92.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H2ZbG-0003dU-1Y
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 12:54:10 -0800
Received: by ug-out-1314.google.com with SMTP id z38so5491672ugc
	for <nfs@lists.sourceforge.net>; Thu, 04 Jan 2007 12:54:05 -0800 (PST)
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20070104194625.GA3000@uio.no>
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

Thanks Steinar.  I'll get to this and the AM_MAINTAINER_MODE patch
soon and resend them to Neil.  (Your other recent patches are out of
my arena.)

K.C.

On 1/4/07, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> Fix an off-by-one in the handling of the -d option to rpc.gssd; this makes
> the option usable again (it would complain that the string was too long).
> This patch is originally by Liam Bedford, and extracted from
>
>   https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/76409
>
> --- nfs-utils-1.0.10.orig/utils/gssd/gssd.c
> +++ nfs-utils-1.0.10/utils/gssd/gssd.c
> @@ -118,7 +118,7 @@ main(int argc, char *argv[])
>                                 break;
>                         case 'd':
>                                 strncpy(ccachedir, optarg, sizeof(ccachedir));
> -                               if (ccachedir[sizeof(ccachedir-1)] != '\0')
> +                               if (ccachedir[sizeof(ccachedir)-1] != '\0')
>                                         errx(1, "ccachedir path name too long");
>                                 break;
>                         default:
>
> /* Steinar */
> --
> Homepage: http://www.sesse.net/
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
