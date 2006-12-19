From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] add missing long option for -r in mountd
Date: Wed, 20 Dec 2006 06:33:42 +1100
Message-ID: <17800.16022.401754.554726@cse.unsw.edu.au>
References: <45881A5B.7080900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwkiO-0006ei-EV
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 11:33:28 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GwkiM-0000gQ-F0
	for nfs@lists.sourceforge.net; Tue, 19 Dec 2006 11:33:30 -0800
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: message from Jeff Layton on Tuesday December 19
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

On Tuesday December 19, jlayton@redhat.com wrote:
> I forgot a bit of code that needs to go into patch 3 that I posted yesterday.
> This adds a long option for the -r option. I'll post manpage update patches
> once I get them written up.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks.

> 
> --- nfs-utils-1.0.10/utils/mountd/mountd.c.longopt
> +++ nfs-utils-1.0.10/utils/mountd/mountd.c
> @@ -67,6 +67,7 @@ static struct option longopts[] =
>   	{ "ha-callout", 1, 0, 'H' },
>   	{ "state-directory-path", 1, 0, 's' },
>   	{ "num-threads", 1, 0, 't' },
> +	{ "reverse-lookup", 0, 0, 'r' },
>   	{ NULL, 0, 0, 0 }
>   };

Your patches have some odd white-space damage. The lines that are
unchanged should start with one space, then a tab, but they actually
start with two spaces, so 'patch' cannot cope at all.  Fortunately
'wiggle' gets it close enough that it is easy to fix by hand, but it
would be nice if you could figure out what is happening.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
