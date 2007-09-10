From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: Question about svc_age_temp_sockets
Date: Mon, 10 Sep 2007 09:04:37 -0500
Message-ID: <1189433077.12145.8.camel@trinity.ogc.int>
References: <200709101033.13929.wolfgang.walter@studentenwerk.mhn.de>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUjtm-0000B8-98
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 07:05:59 -0700
Received: from ms-smtp-02.texas.rr.com ([24.93.47.41])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUjtn-0005Pi-7w
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 07:06:02 -0700
In-Reply-To: <200709101033.13929.wolfgang.walter@studentenwerk.mhn.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-09-10 at 10:33 +0200, Wolfgang Walter wrote:
> > I'm confused about how svc_age_temp_sockets is supposed to work. From my
> > reading, the timer fires every 6 minutes and calls the svc_age_temp_sockets
> > function. This function sweeps the tempsocks list and unconditionally
> > test_and_sets every transport SK_OLD. If it was the first to set it, it
> > will test if the transport's not busy and then shut it down. So here's what
> > I don't get:
> >
> > - A transport that was added 5 minutes into the timer period, could get
> > shut down after only a minute of idleness
> >
> > - A transport that was busy may _never_ get shutdown because it will
> > already have it's SK_OLD bit set when it comes back through 6 minutes
> > later. If no more requests ever arrive from the client, the SK_OLD bit will
> > never get reset and the test_and_set check skips the transport if the bit's
> > already set.
> 
> Hmm, I think it works like that:
> 
> 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
>                         continue;
> 
> So: if SK_OLD is NOT already set then
> 		
> 		  !test_and_set_bit(SK_OLD, &svsk->sk_flags)
> 
> is true and therefor continue is executed (so the transport is not closed,
> only SK_OLD is set).
> 
> If SK_OLD is already set then this evaluates to false and the transport is 
> removed. This means that SK_OLD was set when the timer run the last time and 
> there was no request has arrived since then.

You're right, I misread the !. Duh. So the observation is that it takes
between 6 and 12 minutes to shut down the transport. What does
Connectathon consider reasonable variability?

> 
> >
> > - There's a check for a zero sk_inuse count. I don't see a legitimate way
> > for a socket to be on the tempsocks list with a zero refcount.
> >
> 
> This is something I don't understand, too. See my posting:
> 
> http://marc.info/?l=linux-nfs&m=118927571630268&w=4
> 
> As far as I see it does not work.
> 
> Regards,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
