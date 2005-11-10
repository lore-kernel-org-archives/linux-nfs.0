From: Brian Kerr <kerrboy@gmail.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Thu, 10 Nov 2005 11:18:51 -0500
Message-ID: <b83c9e30511100818s2e176e3bu730e65dfa1cb7d14@mail.gmail.com>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
	 <1130786827.31211.49.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: email builder <emailbuilder88@yahoo.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaFEh-0003Hs-LI
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 08:25:15 -0800
Received: from xproxy.gmail.com ([66.249.82.198])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaFEg-0001RN-8F
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 08:25:15 -0800
Received: by xproxy.gmail.com with SMTP id s6so736613wxc
        for <nfs@lists.sourceforge.net>; Thu, 10 Nov 2005 08:25:10 -0800 (PST)
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1130786827.31211.49.camel@seki.nac.uci.edu>
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

On 10/31/05, Dan Stromberg <strombrg@dcs.nac.uci.edu> wrote:
>
> Most, if not all, of my notes pertaining to large storage are here:
>
> http://dcs.nac.uci.edu/~strombrg/tech-tidbits-by-category.html#Large%20St=
orage
>
> I think commodity hardware is generally a good way to go when you can,
> but we also had bad experiences with some 3Ware RAID cards, though in
> our case, it wasn't clear if the problem was best attributed to the
> Maxtor disks, the 3Ware RAID cards, the Promicrosystems PC's, or the GFS
> and Lustre we tried overtop of this hardware.

I agree that commodity hardware is a good way to go if possible.  I've
had great experience with 3ware cards on Redhat systems if they are
running the latest firmware/driver - horrible experiences otherwise.=20
Also had horrible luck with maxtor drives on 3ware controllers and
maxtor drives in generally - you should think twice about using them.

We see 12MB/sec from multiple clients all day long on RH systems with
this configuration - this is just ata raid on 75xx controllers,
nothing fancy.

Obviously the following options are huge for performance on clients as
well, tcp,rsize=3D8192,wsize=3D8192

The sync option also has a rather large impact on client write
performance and I have left it async for that reason.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
