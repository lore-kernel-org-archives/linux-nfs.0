From: Paul Jakma <paulj@alphyra.ie>
Subject: Re: [PATCH] Secure user authentication for NFS using RPCSEC_GSS
 [0/6]
Date: Mon, 13 Jan 2003 12:22:59 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301131219050.27236-100000@dunlop.admin.ie.alphyra.com>
References: <15906.44145.47417.934888@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dax Kelson <Dax.Kelson@gurulabs.com>,
   NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from itg-gw.cr008.cwt.esat.net ([193.120.242.226] helo=dunlop.admin.ie.alphyra.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Y3cq-0004ha-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 04:23:33 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15906.44145.47417.934888@charged.uio.no>
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

On Mon, 13 Jan 2003, Trond Myklebust wrote:

> Once the root account has been compromised, it is 'Game Over' no
> matter what you do.

Yep.

> Kerberos or no Kerberos, the simplest way to steal your identity is
> simply for the attacker to listen in on your tty while you are
> typing your password.

good point.

> The RPCSEC_GSS security model is not meant to protect you against
> root monitoring. It is meant to prevent some third party (on another
> machine for instance) from spoofing RPC requests in you name (==
> strong authentication), intercepting valid RPC requests and
> modifying the payload (== cryptographic data integrity checking), or
> listening in on the client/server communication (== data privacy).

yes. sorry, i forgot to restrict my comment to "local users are still 
vulnerable to root on that machine". RCPSEC_GSS would close the gap to 
root requiring to be rogue on the same machine as the user root is 
trying to compromise.

BTW: i too very much look forward to using RPCSEC_GSS. very much 
appreciated Trond (et al). !

> Cheers,
>   Trond

regards,
-- 
Paul Jakma	Sys Admin	Alphyra
	paulj@alphyra.ie
Warning: /never/ send email to spam@dishone.st or trap@dishone.st



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
