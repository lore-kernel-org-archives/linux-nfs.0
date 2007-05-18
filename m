From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 2/14] knfsd: delete per transport
Date: Fri, 18 May 2007 16:44:22 +1000
Message-ID: <17997.19270.91547.343390@notabene.brown>
References: <20070516191951.GH9626@sgi.com>
	<17996.12924.211214.309207@notabene.brown>
	<20070518055631.GE5104@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HowCa-0006xw-JR
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:44:37 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HowCc-0008VS-Ts
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:44:39 -0700
In-Reply-To: message from Greg Banks on Friday May 18
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

On Friday May 18, gnb@sgi.com wrote:
> 
> I considered renaming the existing svc_sock to svc_xprt, which
> would be another horribly unpronouncable identifier(*) but would at
> least be appropriately abstract and consistent with the client.
> 
> Then the naming would all be obvious and correct: svc_xprt_foo()
> is a generic transport function, svc_sock_foo() is a more specific
> socket-based transport function used as common code between TCP
> and UDP transports.  Yay.
> 
> But it would be a much larger patch so I shied away.

Sensible.

> 
> I'm happy to do the naming any way you want, just let me know.

I accept that "ipsock" is not accurate (as it is the 'sock' bit that
is significant, the 'ip' is fairly irrelevant) but it is at least
better than tcpip.  Another option is
   svc_detach_sock / svc_free_sock

Which avoid mentioned "svc_sock", but still says what you want.

So go with that, unless you find it objectionable, in which case got
with svc_ipsock_*.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
