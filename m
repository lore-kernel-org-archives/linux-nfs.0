From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS over TCP idle timeout
Date: Mon, 28 Jan 2008 19:32:23 -0500
Message-ID: <20080129003223.GC16785@fieldses.org>
References: <Pine.GSO.4.55.0801251516550.21@loogie.intranet.csupomona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Paul B. Henson" <henson@acm.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760428AbYA2AcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 19:32:24 -0500
In-Reply-To: <Pine.GSO.4.55.0801251516550.21-z2goPYwGszwoNljnaZt3ZkHinNCOp9DfhYY8Ac/fI6A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 25, 2008 at 04:41:00PM -0800, Paul B. Henson wrote:
> 
> Does the Linux server implementation of NFS over TCP implement an idle
> timeout that automatically disconnects clients after some amount of
> inactivity?
> 
> I was testing NFSv4 from a Solaris 10 client to a Linux server (Gentoo,
> 2.6.20). The Solaris client does not tear down the TCP connection upon
> system shutdown, which leaves an orphaned established TCP connection on the
> server. The connection remained in the established state for days.
> 
> Sun support indicates their server automatically disconnects idle clients,
> and don't consider not closing the client connection upon shutdown a bug.
> 
> I didn't find any documentation regarding the Linux implementation and idle
> timeouts, although I did find the following code in net/sunrpc/svcsock.c:
> 
> -----
> /* apparently the "standard" is that clients close
>  * idle connections after 5 minutes, servers after
>  * 6 minutes
>  *   http://www.connectathon.org/talks96/nfstcp.pdf
>  */
> static int svc_conn_age_period = 6*60;
> -----
> 
> that would seem to indicate it should close the connection after some
> amount of idle time? However, empirically that doesn't seem to happen.
> 
> Should idle connections automatically be closed? Are there any tunables or
> switches that need to be touched to enable that?

That sounds like a server bug to me.  Have you checked whether it still
behaves that way on more recent kernels?

--b.
