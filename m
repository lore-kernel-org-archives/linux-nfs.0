From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] reply-cache - RC_DELAY
Date: Tue, 19 Aug 2003 09:02:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16193.23320.981178.178768@gargle.gargle.HOWL>
References: <Pine.LNX.4.33.0308181412430.1203-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ot1g-0002rv-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 16:03:00 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 19 Aug 2003 09:02:53 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Monday August 18
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

On Monday August 18, markhe@veritas.com wrote:
>   Do not update 'c_timestamp' for a "too fast" retransmit.  Otherwise, it
> is possible we'll never re-send to a client which is constantly being
> over-eager - or is this the idea?
> 
>   Also, protect against jiffies wrap.
> 

Best not to combine two changes in the one patch, incase I like one
but not the other....

In this case, I'm not at all convinced aboutt he jiffy-wrap thing.
As age, jiffies, and c_timestamp are all "unsigned long", I don't see
how the new code generates a different result... 
Actually it does generate a different result, an incorrect result.
~0 == -1, so
   age += ~0UL - rp->c_timestamp
is like
   age = age - 1 - rp->c_timestamp

which is wrong.

The RC_DELAY bit is probably OK, but if we are getting the same
request every 200ms, then something is really wrong with the client,
and maybe we do want to ignore it altogether.

If you feel strongly enough about it to send it again without the
jiffy-wrap stuff, I'll accept it though.

NeilBrown

> Thanks,
> Mark
> 
> 
> diff -urNp linux-2.6.0-test3/fs/nfsd/nfscache.c linux-2.6.0-test3-nfsd-age/fs/nfsd/nfscache.c
> --- linux-2.6.0-test3/fs/nfsd/nfscache.c	2003-08-09 05:42:23.000000000 +0100
> +++ linux-2.6.0-test3-nfsd-age/fs/nfsd/nfscache.c	2020-08-18 13:46:31.033864560 +0100
> @@ -252,13 +252,25 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
> 
>  found_entry:
>  	/* We found a matching entry which is either in progress or done. */
> -	age = jiffies - rp->c_timestamp;
> +
> +	/* careful of wrap */
> +	age = jiffies;
> +	if (age >= rp->c_timestamp) {
> +		age -= rp->c_timestamp;
> +	} else {
> +		age += (~0UL - rp->c_timestamp);
> +	}


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
