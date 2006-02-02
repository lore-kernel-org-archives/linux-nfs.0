From: Brian Kerr <kerrboy@gmail.com>
Subject: Re: NFS reliability in Enterprise Environment
Date: Wed, 1 Feb 2006 19:08:25 -0500
Message-ID: <b83c9e30602011608s6ba5b8d9sc2c9b01e27740ce0@mail.gmail.com>
References: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4S1Y-0004vq-1r
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 16:08:32 -0800
Received: from xproxy.gmail.com ([66.249.82.199])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F4S1T-0004qV-LU
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 16:08:31 -0800
Received: by xproxy.gmail.com with SMTP id s6so189023wxc
        for <nfs@lists.sourceforge.net>; Wed, 01 Feb 2006 16:08:26 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
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

On 2/1/06, David Sullivan <david.sullivan@activant.com> wrote:
>
> Does anyone have any data they can share on the reliability of Linux NFS
> servers (not clients) in an enterprise environment (e.g. server uptimes,
> number of volumes shared, number of clients, IO rates)?  I have a large
> enterprise application set (about 10K programs) that uses NFS for
> file-sharing.  A movement is afoot at my company to port the applications
> from the more expensive "big iron" Unix systems it is currently deployed =
on
> to less expensive Linux x86 servers.  I'm trying to do a baseline risk
> assessment of this move, and I'd like some empirical data (or some
> speculative) on the reliability of NFS.  Even better would be a contrast =
in
> reliability to shared-storage filesystems like GFS or OCFS2.
er tcp(only).

While I can't share exact IO and stats I can tell you that it keeps up
with netapp filers that consistently push 40-80MBit/second 24/7/365.=20
Be sure to do some research on kernel and hardware obviously and you
should be good.

I would be interested to hear of anyone else using GFS in an NFS
implmentation.  Shortly we will be moving some NFS servers to large
storage arrays and we need all NFS servers to see the same filesystems
for redundancy and scalability.  From what I've gathered GFS is ready
for primetime - I would love to hear how it works from a NFS
perspective.

-Brian


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
