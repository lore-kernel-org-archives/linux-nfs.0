From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [BUG] [FIX] warning on NFS readlink
Date: Wed, 18 Sep 2002 15:06:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15752.2539.632270.902524@notabene.cse.unsw.edu.au>
References: <20020917.170132.58443699.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rX3T-00033C-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 22:07:16 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 18 Sep 2002 15:06:55 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Tuesday September 17
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Tuesday September 17, taka@valinux.co.jp wrote:
> Hello,
> 
> I found a trivial problem that kernel might warn "RPC request reserved
> 1144 but used 1936" when NFS-readlink is requested.
> This case will happen when symbolic-link file is very big
> as nfsd_procedure3[] table assumes max-size of symbolic-link file is
> 256 bytes.
> It should be change to NFS3_MAXPATHLEN.

Thanks.

The numbers in the tables are actually in units of 4bytes (32 bits),
so we need
   NFS_MAXPATHLEN/4
and
   NFS3_MAXPATHLEN/4

so the number in nfsproc was actually correct (though using the
symbolic value us better).  The number in nfs3proc was wrong as
NFS3_MAXPATHLEN is 4096.

I'll send patches off to Linus and Marcelo shortly.

NeilBrown

> 
> 
> Here is a patch against linux-2.5.35.
> And we should also fix it on linux-2.4.19.
> 
> Thank you,
> Hirokazu Takahashi.
> 
> --- linux.ORG/fs/nfsd/nfsproc.c	Mon Sep 16 11:18:25 2002
> +++ linux/fs/nfsd/nfsproc.c	Tue Sep 17 16:07:04 2030
> @@ -545,7 +545,7 @@ struct svc_procedure		nfsd_procedures2[1
>    PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
>    PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
>    PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
> -  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+256),
> +  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN),
>    PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
>    PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
>    PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
> --- linux.ORG/fs/nfsd/nfs3proc.c	Mon Sep 16 11:18:26 2002
> +++ linux/fs/nfsd/nfs3proc.c	Tue Sep 17 16:06:41 2030
> @@ -670,7 +670,7 @@ struct svc_procedure		nfsd_procedures3[2
>    PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
>    PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
>    PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
> -  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+256),
> +  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN),
>    PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
>    PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
>    PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
> 
> 
> 
> -------------------------------------------------------
> Sponsored by: AMD - Your access to the experts on Hammer Technology! 
> Open Source & Linux Developers, register now for the AMD Developer 
> Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
