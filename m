From: James Pearson <james-p@moving-picture.com>
Subject: Re: bug in linux mount? (says NetApp)
Date: Wed, 12 Jul 2006 10:32:08 +0100
Message-ID: <44B4C198.2070609@moving-picture.com>
References: <44B3F547.9010507@amd.com>
	<1152660478.5681.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0b4y-0002GM-TC
	for nfs@lists.sourceforge.net; Wed, 12 Jul 2006 02:32:25 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0b4x-0007Ug-Kv
	for nfs@lists.sourceforge.net; Wed, 12 Jul 2006 02:32:25 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1152660478.5681.38.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> 
> It has nothing to do with the mount timeout: Chuck is talking about the
> retransmission timeout for TCP connections 'timeo' which should indeed
> be set to a high value since TCP guarantees message delivery (unlike UDP
> which requires a small timeo value). Setting it too low means that you
> end up spamming your server with a load of unnecessary retransmissions.
> 
> This was indeed the case for some older versions of 'mount' and also for
> older versions of the am-utils/amd automounters.

Do you know how you tell what value of timeo is being used by default?

The source code for mount (nfsmount.c, part of util-linux v2.12) has the 
comment:

   /* timeo is filled in after we know whether it'll be TCP or UDP */

Can I assume, in this case, the value of timeo will be a suitable value 
for tcp mounts?

Thanks

James Pearson


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
