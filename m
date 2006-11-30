From: Roger Heflin <rheflin@atipa.com>
Subject: Re: Terrible performance between 2.6.16 and 2.6.5
Date: Thu, 30 Nov 2006 08:24:26 -0600
Message-ID: <456EE99A.90009@atipa.com>
References: <456EC5D1.9050008@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gpmpw-0006y9-Pj
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 06:24:29 -0800
Received: from 125.14.cm.sunflower.com ([24.124.14.125] helo=mail.atipa.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gpmpw-0002WP-R5
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 06:24:30 -0800
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
In-Reply-To: <456EC5D1.9050008@bio.ifi.lmu.de>
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

Frank Steiner wrote:
> Hi,
> 
> I just upgraded our NFS server from SuSE 9.2 (kernel 2.6.8) to SuSE 10.1
> (2.6.16.21). We have some SLES 9 (2.6.5) and some SLES 10 (2.6.16) clients
> acessing the NFS server.
> 
> When the server ran 2.6.8, the performance was always fine. After upgrading
> the SLES 10 clients still have nice performance, but the SLES 9 clients
> are terrible.
> 
> Here's a test call I'm doing:
>   find /mnt/tmp/i586/9/SuSE-updates/ -name \*.rpm -exec rpm -qp {} \;
> It just queries all the rpm packages for their name.
> 
> When I call this on a SLES 10 client I can monitor the network traffic
> on the server lies between 200k and some little peaks at 1.5M.
> 
> Calling it on a SLES9 client looks fine at first, then after some RPMs
> the network traffic raises to about 20-30 MB/sec! Guess what the server
> says when 30 clients search for new RPMs with an algorithm similar to this.
> 
> When I call the "find" a second time on the same SLES 9 clients it runs
> fine for some longer time, like it had cached the accesses or if it had some
> buffer that would fill and then slow the read down.
> 
> On all clients we mount with "ro,tcp,hard,rsize=16384,wsize=16384".
> Changing sync/async on the server and the clients didn't help.
> 
> Are there any known issues? Any ideas how I could debug this? We
> can't throw away SLES 9 on these clients, so I need to solve this :-(
> 
> cu,
> Frank

Frank,

What is the type of the underlying disk subsystem?  Did the underlying
disk subsystem's performance change or is it the same?   You may need
to run bonnie or something similar to verify that the disk hardware
is not where the issue is.

I have seen the MPT driver in the later kernels be quite a bit
slower (3x) with certain combinations of devices.

And there are a fair number of issues were various other disk
devices from time to time get much slower in newer kernels, but
are fine in older kernels.

                                 Roger

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
