From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] [PATCH] CLOSE_WAIT sockets may remain forever
Date: Mon, 16 Jun 2003 11:59:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16109.9343.339819.34212@gargle.gargle.HOWL>
References: <20030611.214512.123409801.taka@valinux.co.jp>
	<20030614.010949.48529350.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19RjD9-0001gQ-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Jun 2003 18:55:07 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Mon, 16 Jun 2003 11:55:00 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Saturday June 14
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

On Saturday June 14, taka@valinux.co.jp wrote:
> Hello,
> 
> I also realized that one more patch is needed.
> 
> > I found a bug that CLOSE_WAIT sockets may remain forever on an
> > NFS server when NFS client is IRIX6.5 .
> > IRIX6.5 try to connect the server twice. I guess the first trial is
> > checking capability of the server and it closes the socket
> > immediately without sending data.
> > 
> > In this case the Linux server can't close a newly established
> > socket as it isn't accepted yet.
> > There are no problems if it's a typical NFS client which
> > sends data after establishing connection.
> 
> Potentially NFS clients might close the socket before it is accepted
> by an NFS server. This may leaves CLOSE_WAIT sockets since there are
> no chances to set a SK_CLOSE flag on it.
> 
> We should apply these patches or it might become a target of a DOS attack.
> 

Thanks for these.  They seem to make sense.
I'll do a bit of testing and then pass them on.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
