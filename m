From: Ian Kent <raven@themaw.net>
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Wed, 31 Dec 2003 09:55:11 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0312310858190.5698-100000@wombat.indigo.net.au>
References: <200312301744.hBUHiVX01743@supercomputer.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbVad-0005vU-Uc
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 17:56:03 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AbVad-00079W-8q
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 17:56:03 -0800
To: <dwight@supercomputer.org>
In-Reply-To: <200312301744.hBUHiVX01743@supercomputer.org>
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

On Tue, 30 Dec 2003 dwight@supercomputer.org wrote:

> Thank you for asking. I was referring to standard RedHat releases (7.x on up)
> with the default settings. I'd be interested in knowing if you or anyone
> else has any experience to the contrary.

I have 7.1 and 7.3 clients. Haven't had many problems over the years and
the recent 2.4 kernels are much improved.

Currently I'm running the RedHat 2.4.20-20.7 kernel.

I used UDP transport for a long time but have recently changed to TCP for
nearly all my clients.

>
> As far as tuning goes, that gets rather extensive, from the MTU on up to the
> NFS r/w sizes, as well as even the network topology. Since the options are
> numerous and specific to one's environment, let me ask a simpler question: Has
> anyone been able to tune a Linux-client and Solaris-server combination such
> that the speed is comparable to a pure Linux or a pure Solaris client/server
> combination? This is for heavy r/w access.

My usage is largely read.

Performance has improved quite a bit as the kernel version has increased.
I can get around 80% (ie. 80% wire speed) the throughput of a 'similar'
Sun. Problem is that most of the Sparc clients can saturate 100Mb (onto a
gigabit backbone) so I don't really know what the difference is.

Ian




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
