From: Neil Brown <neilb@suse.de>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets
	work (was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 16:14:06 +0200
Message-ID: <18151.62510.891210.485277@notabene.brown>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVT09-0004Vu-Qh
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 07:15:34 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IVT0D-0001p7-O1
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 07:15:38 -0700
In-Reply-To: message from Wolfgang Walter on Wednesday September 12
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

On Wednesday September 12, wolfgang.walter@studentenwerk.mhn.de wrote:
> Hello,
> 
> as already described old temporary sockets (client is gone) of lockd aren't
> closed after some time. So, with enough clients and some time gone, there
> are 80 open dangling sockets and you start getting messages of the form:
> 
> lockd: too many open TCP sockets, consider increasing the number of nfsd threads.
> 
> If I understand the code then the intention was that the server closes
> temporary sockets after about 6 to 12 minutes:
> 
> 	a timer is started which calls svc_age_temp_sockets every 6 minutes.
> 
> 	svc_age_temp_sockets:
> 		if a socket is marked OLD it gets closed.
> 		sockets which are not marked as OLD are marked OLD
> 
> 	every time the sockets receives something OLD is cleared.
> 
> But svc_age_temp_sockets never closes any socket though because it only
> closes sockets with svsk->sk_inuse == 0. This seems to be a bug.
> 
> Here is a patch against 2.6.22.6 which changes the test to
> svsk->sk_inuse <= 0 which was probably meant. The patched kernel runs fine
> here. Unused sockets get closed (after 6 to 12 minutes)
> 
> Signed-off-by: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
> 
> --- ../linux-2.6.22.6/net/sunrpc/svcsock.c	2007-08-27 18:10:14.000000000 +0200
> +++ net/sunrpc/svcsock.c	2007-09-11 11:07:13.000000000 +0200
> @@ -1572,7 +1575,7 @@
>  
>  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
>  			continue;
> -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
> +		if (atomic_read(&svsk->sk_inuse) <= 0 || test_bit(SK_BUSY, &svsk->sk_flags))
>  			continue;
>  		atomic_inc(&svsk->sk_inuse);
>  		list_move(le, &to_be_aged);
> 
> 
> As svc_age_temp_sockets did not do anything before this change may trigger
> hidden bugs.
> 
> To be true I don't see why this check
> 
> (atomic_read(&svsk->sk_inuse) <= 0 || test_bit(SK_BUSY, &svsk->sk_flags))
> 
> is needed at all (it can only be an optimation) as this fields change after
> the check. In svc_tcp_accept there is no such check when a temporary socket
> is closed.

Thanks for looking into this.

I think the correct change is to test
		if (atomic_read(&svsk->sk_inuse) > 1 || test_bit(SK_BUSY, &svsk->sk_flags))
or even
		if (atomic_read(&svsk->sk_inuse) != 1 || test_bit(SK_BUSY, &svsk->sk_flags))

sk_inuse contains a bias of '1' until SK_DEAD is set.  So a normal,
active socket will have an inuse count of 1 or more.  If it is exactly
1, then either it is SK_DEAD (in which case there is nothing for this
code to do), or it has no users, in which case it is appropriate to
close the socket if it is old.
Note that this test is for "the socket should not be closed", so we
test if it is *not* 1, or > 1.

The tests are needed because we don't want to close a socket that
might be inuse elsewhere.  The SK_BUSY bit combined with the sk_inuse
count combine to check if the socket is in use at all or not.

You change effectively disabled the test, as sk_inuse is never <= 0
(except when SK_DEAD is set).

This bug has been present since 
commit aaf68cfbf2241d24d46583423f6bff5c47e088b3
Author: NeilBrown <neilb@suse.de>
Date:   Thu Feb 8 14:20:30 2007 -0800

(i.e. it is my fault).
So it is in 2.6.21 and later and should probably go to .stable for .21
and .22.

Bruce:  for you :-)
---------------------------
Correctly close old nfsd/lockd sockets.

From: NeilBrown <neilb@suse.de>

Commit aaf68cfbf2241d24d46583423f6bff5c47e088b3 added a bias
to sk_inuse, so this test for an unused socket now fails.  So no
sockets gets closed because they are old (they might get closed
if the client closed them).

This bug has existed since 2.6.21-rc1.

Thanks to Wolfgang Walter for finding and reporting the bug.


Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-09-12 16:05:23.000000000 +0200
+++ ./net/sunrpc/svcsock.c	2007-09-12 16:06:01.000000000 +0200
@@ -1592,7 +1592,8 @@ svc_age_temp_sockets(unsigned long closu
 
 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
 			continue;
-		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
+		if (atomic_read(&svsk->sk_inuse) > 1
+		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
 		atomic_inc(&svsk->sk_inuse);
 		list_move(le, &to_be_aged);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
