From: Neil Brown <neilb@suse.de>
Subject: Re: mountd memory leaks in 1.0.12
Date: Fri, 16 Mar 2007 11:27:07 +1100
Message-ID: <17913.58459.646060.279300@notabene.brown>
References: <20070306125230.GA30735@uio.no>
	<20070306145907.GA31463@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS0Hs-0002ZR-0U
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:27:16 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HS0Hs-0001pk-UA
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 17:27:18 -0700
In-Reply-To: message from Steinar H. Gunderson on Tuesday March 6
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

On Tuesday March 6, sgunderson@bigfoot.com wrote:
> On Tue, Mar 06, 2007 at 01:52:30PM +0100, Steinar H. Gunderson wrote:
> > Over time, this amounts to gigabytes of RAM on a busy server. Either the
> > blkid library is generally really leaky (in which case we probably shouldn't
> > be using it until it's fixed), or we're using it wrong somehow. :-)
> 
> I found the leaks in libblkid (see the separate e-mail I sent). This patch
> fixes a minor leak in mountd itself, and with the patch applied and a fixed
> libblkid, it appears that mountd is no longer leaking memory.
> 
> --- nfs-utils-1.0.12.orig/support/export/client.c       2007-03-06 15:51:39.000000000 +0100
> +++ nfs-utils-1.0.12/support/export/client.c    2007-03-06 15:51:53.000000000 +0100
> @@ -329,6 +329,7 @@
>                 strcat(new, ",");
>                 strcat(new, cp);
>         }
> +       free(old);
>         return new;
>  }


Thanks.  I've finally added it to git.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
