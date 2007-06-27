From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: 2.6.21.x kernel panic (tg3 and nfs related)
Date: Wed, 27 Jun 2007 11:58:18 -0400
Message-ID: <4682891A.2070900@redhat.com>
References: <20070627101608.GQ22589@skl-net.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	mchan@broadcom.com
To: Andre Noll <maan@systemlinux.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3ZuR-0003ZD-Ds
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 08:58:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3ZuQ-0004yW-KE
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 08:58:27 -0700
In-Reply-To: <20070627101608.GQ22589@skl-net.de>
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

On 06/27/2007 06:16 AM, Andre Noll wrote:
> Hi
> 
> Our nfs server recently paniced under heavy nfs load. The backtrace
> indicates that this might be a problem with the tigon3 network driver
> which drives the onboard chips of the machine.
> 
> The first crash under 2.6.21.1 happened after about 4 days of uptime, 
> 2.6.21.5 already crashed after 15 Minutes.
> 
> Screenshots of the resulting kernel panics are available at
> 
> 	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.1.png
> and
> 	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.5.png
> 

Looks the the known oops in show_mem(); patch is queued for 2.6.21.6.

But it is hard to tell when the screen shot doesn't show the whole
message...

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
