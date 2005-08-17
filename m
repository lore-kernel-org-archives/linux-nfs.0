From: Richard Perrin <rcp@sentientmeat.ca>
Subject: Re: Hang in 2.6.11.11 NFSv3 client following NFSERR_JUKEBOX
Date: Wed, 17 Aug 2005 12:29:35 -0400
Message-ID: <20050817162935.GA27682@sentientmeat.ca>
References: <20050817133257.GK13622@sentientmeat.ca> <1124288152.23245.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5QuE-0001LW-5r
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 09:36:46 -0700
Received: from smtp104.rog.mail.re2.yahoo.com ([206.190.36.82])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E5QuB-0002Yk-Hg
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 09:36:46 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1124288152.23245.31.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, Aug 17, 2005 at 10:15:52AM -0400, Trond Myklebust wrote:
> on den 17.08.2005 Klokka 09:32 (-0400) skreiv Richard Perrin:
> > Summary:
> > After receiving an ERR_JUKEBOX, client does not appear to resend request.
> 
> Have you tried with 2.6.13-pre6 or any of the other kernels that has the
> "sunrpc_timer_restart" patch applied? 
> 
> see
> http://client.linux-nfs.org/Linux-2.6.x/2.6.12/linux-2.6.12-01-sunrpc_timer_restart.dif

Applied the patch to 2.6.11.11 and it fixes the problem, duplicating
the behaviour seen in the 2.4 kernel.

Thanks for the fix,
- Richard

-- 
Richard Perrin
richard.perrin@solacesystems.com
rcp@sentientmeat.ca


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
