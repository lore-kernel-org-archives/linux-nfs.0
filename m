From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Fri, 22 Apr 2005 09:43:02 -0400
Message-ID: <1114177382.10450.54.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
	 <1114042784.17214.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
	 <1114088708.10727.9.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
	 <1114118453.12750.44.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
	 <1114176705.10450.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6zvSqInpFjH6ACMVtKY5"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOyRI-0007Om-8G
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 06:43:24 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOyRH-0008QL-Lc
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 06:43:24 -0700
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <1114176705.10450.43.camel@lade.trondhjem.org>
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


--=-6zvSqInpFjH6ACMVtKY5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


> > I'm able to reproduce this problem. I have a screen shot of the call trace 
> > on http://www.cendio.se/~peter/fc3-umount-crash.png, if anyone is 
> > interested.
> 
> That's certainly an "interesting" Oops. ebp=0x1b, esp=0xc0446f98,
> together with a timer list corruption. Is that running under vmware? If
> so, can you reproduce with a normal kernel (no vmware module) and given
> that weird value of ebp, with stack overflow checking turned on.
> 
> On my machine, the "umount -f" complains a bit about "Cannot MOUNTPROG
> RPC (tcp): RPC: Program not registered", and there may be a few "device
> is busy" here and there, but the umount definitely succeeds in killing
> off the hanging programs, and it fails to Oops.

Hmm... Moments after I replied, I got this mail on the LKML list.

Could you describe the test you are using to reproduce your Oops in more
detail? How are you causing the network partition?

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-6zvSqInpFjH6ACMVtKY5
Content-Disposition: inline
Content-Description: Vedlagt melding - Crash when unmounting NFS/TCP with -f
Content-Type: message/rfc822

Return-Path: <Brice.Goglin@ens-lyon.org>
Received: from mail-imap5.uio.no ([unix socket]) by mail-imap5.uio.no
	(Cyrus v2.2.10) with LMTPA; Fri, 22 Apr 2005 14:32:14 +0200
X-Sieve: CMU Sieve 2.2
Delivery-date: Fri, 22 Apr 2005 14:32:14 +0200
Received: from mail-mx4.uio.no ([129.240.10.45]) by mail-imap5.uio.no with
	esmtp (Exim 4.43) id 1DOxKQ-0007ji-D0 for trond.myklebust@fys.uio.no; Fri,
	22 Apr 2005 14:32:14 +0200
Received: from bernache.ens-lyon.fr ([140.77.167.10]) by mail-mx4.uio.no
	with esmtp (Exim 4.43) id 1DOxKO-0007sN-85 for trond.myklebust@fys.uio.no;
	Fri, 22 Apr 2005 14:32:12 +0200
Received: by bernache.ens-lyon.fr (Postfix, from userid 103) id
	D5C917ABD4B; Fri, 22 Apr 2005 14:32:10 +0200 (CEST)
Received: from [140.77.13.107] (puligny.cri2000.ens-lyon.fr
	[140.77.13.107]) (using TLSv1 with cipher RC4-MD5 (128/128 bits)) (Client
	did not present a certificate) by bernache.ens-lyon.fr (Postfix) with ESMTP
	id 51BD97ABD46; Fri, 22 Apr 2005 14:32:10 +0200 (CEST)
Message-ID: <4268EEC9.8010305@ens-lyon.org>
Date: Fri, 22 Apr 2005 14:32:09 +0200
From: Brice Goglin <Brice.Goglin@ens-lyon.org>
User-Agent: Mozilla Thunderbird 1.0 (X11/20050116)
X-Accept-Language: fr, en
MIME-Version: 1.0
To: trond.myklebust@fys.uio.no
Cc: linux-kernel@vger.kernel.org
Subject: Crash when unmounting NFS/TCP with -f
X-Enigmail-Version: 0.90.0.0
X-Enigmail-Supports: pgp-inline, pgp-mime
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
X-Spam-Checker-Version: SpamAssassin 2.64 (2004-01-11) on
	bernache.ens-lyon.fr
X-Spam-Report: 
X-Spam-Status: No, hits=0.0 required=5.0 tests=none autolearn=no
	version=2.64
X-Spam-Level: 
X-MailScanner-Information: This message has been scanned for viruses/spam.
	Contact postmaster@uio.no if you have questions about this scanning
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=0.551, required 12,
	autolearn=disabled, AWL 0.55)
X-Evolution-Source: imap://trondmy@imap.uio.no/
Content-Transfer-Encoding: 7bit

Hi Trond,

I'm using NFS (v2) over TCP (in a SSH tunnel).
Each time the SSH dies before a umount NFS, I have to umount -f
and I get a crash (only sysrq works).
Actually, the crash occurs a few seconds after umount -f.

It seems that killing SSH by hand does _not_ lead to crash.
But a long network failure does.
I remember seeing this bug several times with all stable releases
from 2.6.7 to 2.6.11. I didn't try with earlier versions.

I didn't see anything in the logs (after reboot). But I can't be sure
there was nothing in dmesg since I didn't get a chance to chvt 1 and
see console messages before rebooting (with sysrq).

Do you have any idea how to debug this ?

Thanks,
Brice

--=-6zvSqInpFjH6ACMVtKY5--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
