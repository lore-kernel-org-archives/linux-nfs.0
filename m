From: Neil Brown <neilb@suse.de>
Subject: Re: Regression: NFS locking hangs when statd not running.
Date: Tue, 24 Oct 2006 11:26:43 +1000
Message-ID: <17725.27603.724326.910277@cse.unsw.edu.au>
References: <17720.41873.549441.330938@cse.unsw.edu.au>
	<20061020124119.GE27351@suse.de>
	<76bd70e30610200600o2269db3ex2448982fb3e25d46@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Takashi Iwai <tiwai@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcB4A-0002Ya-Rt
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:26:54 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcB4A-0001yJ-DS
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 18:26:56 -0700
To: "Chuck Lever" <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Friday October 20
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

On Friday October 20, chucklever@gmail.com wrote:
> 
> Copying the intr flag makes sense.  Neil, I'd like to see your patch
> address this too.

I'll see what I can do... but not for lockd requests.  See previous mail

> 
> The hard v. soft issue is more difficult.  The semantic you are
> requesting for the local statd is clearly "soft" and that's what you
> say you always want.  Otherwise copying the soft flag makes sense.
> 
> Maybe you can re-use the soft flag and expose a way to set the soft
> timeout for the mon client to get the exact behavior you want?

It's not really about timeouts - or about 'soft'.  It is about getting
a definite 'no' answer (either from portmap or the network stack) and
believing it, which is only safe when talking to a local service
.... hmmm.  Maybe that is also safe when doing the initial 'ping'.
That is currently always 'soft' and presumably 'expects' the server to
be there and functional so a 'no' reply could reasonably be believed
there.

Looking more at where and initial ping is used, I notice that the
lockd client does a (soft) ping first.  So if you have a hard mount,
the first lock request can still fail due to an unresponsive server
because the ping will fail... Shouldn't lockd clients be created with
NO_PING ??

NeilBrown

> 
> -- 
> "We who cut mere stones must always be envisioning cathedrals"
>    -- Quarry worker's creed
A colleague as a message on his wall something like:
  If you want to build great boats, teach your workers to yearn for
  the wide open oceans.

or something like that. :-)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
