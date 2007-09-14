From: Greg Banks <gnb@sgi.com>
Subject: Re: Question about svc_age_temp_sockets
Date: Fri, 14 Sep 2007 19:19:53 +1000
Message-ID: <20070914091953.GE21965@sgi.com>
References: <200709101033.13929.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IW7L5-0001Uz-MJ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 02:19:51 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+3/QiDd6iO48fvBthAi+ZCMFok3SMve8I=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IW7LA-0007VN-BZ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 02:19:56 -0700
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

On Mon, Sep 10, 2007 at 10:33:13AM +0200, Wolfgang Walter wrote:
> > I'm confused about how svc_age_temp_sockets is supposed to work.
> > [...]
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

That's right, it's mark-and-sweep.  The SK_OLD bit indicates
"no requests have been received since the last ageing timer".
If it's seen in the next ageing timer, then the socket had been
idle for between 1 and 2 timer periods and thus may be shut down.

Greg
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
