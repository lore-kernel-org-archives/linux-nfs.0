From: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Subject: Re: Bug: 2.5.47 NFS reports giant filename in readdir
Date: Tue, 19 Nov 2002 18:39:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021119173951.1270.qmail@linuxmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 205-158-62-68.outblaze.com ([205.158.62.68] helo=spf0.us4.outblaze.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ECrf-0001Ok-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Nov 2002 10:12:47 -0800
To: trond.myklebust@fys.uio.no,
  "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I applied the patch to 2.4.20-rc2 but it isn't still working 100%.

Now, when I do an "ls" over the same NFS-mounted directory, I do only get a partial list of files (~500 files of 17000)... "dmesg" on 2.4.20-rc2 reveals the following message:

   NFS: readdir reply truncated!

Any more ideas? :-)

----- Original Message -----
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 18 Nov 2002 21:47:04 +0100
To: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Subject: Re: [NFS] Bug: 2.5.47 NFS reports giant filename in readdir


> >>>>> " " == Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> writes:
> 
>      > The last command produces an empty listing, even when the
>      > directory contains 16694 files on it. When I do a "dmesg" on my
>      > 2.4.20-rc1 machine, I see the following errors:
> 
> Sigh. Yep. It's a known issue with 2.4.20-rc1 and rc2. Fix is
> 
> http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-00-fix_overflow.dif
> 
> 
> Cheers,
>   Trond
> 

-- 
______________________________________________
http://www.linuxmail.org/
Now with POP3/IMAP access for only US$19.95/yr

Powered by Outblaze


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
