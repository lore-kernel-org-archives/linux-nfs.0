From: "Steve Costaras" <stevecs@oceanbay.com>
Subject: Re: limit on filesystem size?
Date: Fri, 2 Aug 2002 16:26:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <008401c23a6b$489bd8c0$fd0912ac@analytical>
References: <20020801195309.GA26793@stikine.ucs.sfu.ca> <shs7kja48km.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cosmos.oceanbay.com ([65.172.145.163] helo=oceanbay.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ajwp-0003uD-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 14:26:59 -0700
To: "Martin Siegert" <siegert@sfu.ca>,
   "Trond Myklebust" <trond.myklebust@fys.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

How are you planning on creating this filesystem?    I have tried
creating 2TB filessystems here for a while and have had little or no
luck w/ Solaris or linux.  Using Disksuite for solaris and LVM and MD for
linux no luck.  I have not tried veritas VM yet but even calling up SUN
the answer is that 1TB is the limit per filesystem currently under solaris 8
& 9

Linux is really around 980GB or so where it starts to flake out.


Steve
----- Original Message -----
From: "Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Martin Siegert" <siegert@sfu.ca>
Cc: <nfs@lists.sourceforge.net>
Sent: Thursday, August 01, 2002 15:39
Subject: Re: [NFS] limit on filesystem size?


> >>>>> " " == Martin Siegert <siegert@sfu.ca> writes:
>
>      > Hello, we are in the planning process for the setup of a large
>      > (~ 100 TB) NFS server. My understanding is that there is a
>      > limit of 2TB for filesystem sizes for local (!) filesystems
>      > under Linux (at least for ext2/ext3; I am not sure about xfs).
>
>      > My question really is: is there a limit for the filesystem size
>      > that a Linux NFS client (2.4.18 or the upcoming 2.4.19 kernel)
>      > can mount from a (possibly non-Linux) NFS server?  E.g., can I
>      > mount a 20TB filesystem under Linux?
>
>      > (I've asked this question on the beowulf mailing list and the
>      > answer was no. Now I ask the experts - hoping for a different
>      > answer :-)
>
> If you can mount it, then you can export it...
>
> For NFSv2 there is a 32-bit size limit on the files you can export
> whereas for NFSv3, that limit is 64-bits, but those limits are
> *per-file*.
>
> Otherwise, you might run into problems when you try to run 'df' in
> order to read filesystem statistics (NFSv2, the limit is 41-bit
> - NFSv3 the limit is 64-bit) but that shouldn't really be a critical
>  feature.
>
> Cheers,
>   Trond
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
