Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48104 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041Ab1CJAtM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Mar 2011 19:49:12 -0500
Date: Wed, 9 Mar 2011 16:48:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Maciej Rutecki <maciej.rutecki@gmail.com>,
        Florian Mickler <florian@mickler.org>,
        "Ben Hutchings" <bhutchings@solarflare.com>,
        "Pavel Emelyanov" <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        David Miller <davem@davemloft.net>
Subject: Re: [Bug #30322] BUG in xs_tcp_setup_socket
Message-Id: <20110309164844.decd835f.akpm@linux-foundation.org>
In-Reply-To: <sUKqYsqyJ4N.A.n0F.3-3cNB@chimera>
References: <dtUMITvTCCN.A.uuF.y-3cNB@chimera>
	<sUKqYsqyJ4N.A.n0F.3-3cNB@chimera>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun,  6 Mar 2011 13:40:43 +0100 (CET)
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> This message has been generated automatically as a part of a report
> of regressions introduced between 2.6.36 and 2.6.37.
> 
> The following bug entry is on the current list of known regressions
> introduced between 2.6.36 and 2.6.37.  Please verify if it still should
> be listed and let the tracking team know (either way).
> 
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=30322
> Subject		: BUG in xs_tcp_setup_socket
> Submitter	: Ben Hutchings <bhutchings@solarflare.com>
> Date		: 2011-03-01 20:34 (6 days old)
> Patch		: http://article.gmane.org/gmane.linux.nfs/38949
> 

Ben's patch is a no-brainer but it is not yet in mainline or linux-next. 
I'm not on linux-nfs so I recreated it as below.


Subject: sunrpc: propagate errors from xs_bind() through xs_create_sock()
From: Ben Hutchings <bhutchings@solarflare.com>

xs_create_sock() is supposed to return a pointer or an ERR_PTR-encoded
error, but it currently returns 0 if xs_bind() fails.  This causes the
kernel to go BUG, as described in
https://bugzilla.kernel.org/show_bug.cgi?id=30322.


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: David Miller <davem@davemloft.net>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/xprtsock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/sunrpc/xprtsock.c~sunrpc-propagate-errors-from-xs_bind-through-xs_create_sock net/sunrpc/xprtsock.c
--- a/net/sunrpc/xprtsock.c~sunrpc-propagate-errors-from-xs_bind-through-xs_create_sock
+++ a/net/sunrpc/xprtsock.c
@@ -1631,7 +1631,8 @@ static struct socket *xs_create_sock(str
 	}
 	xs_reclassify_socket(family, sock);
 
-	if (xs_bind(transport, sock)) {
+	err = xs_bind(transport, sock);
+	if (err) {
 		sock_release(sock);
 		goto out;
 	}
_

