From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Tue, 14 May 2002 08:47:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205140847.58123.trond.myklebust@fys.uio.no>
References: <3CDFCE9F.2BE050D5@fnal.gov> <shswuu8ytk4.fsf@charged.uio.no> <3CDFEFB4.D22CF52D@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177W6R-0005zX-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 23:48:07 -0700
To: Dan Yocum <yocum@fnal.gov>
In-Reply-To: <3CDFEFB4.D22CF52D@fnal.gov>
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

M=E5ndag 13. mai 2002 18:54 skreiv Dan Yocum:
> Trond,
>
> Nothing special in /var/log/messages on either the client or server tha=
t
> would help in debugging the problem, unfortunately.
>
> I'm seeing the problem on these 2 client systems:
>
> vanilla 2.4.18 + linux-2.4.18-NFS_ALL.dif - linux-2.4.18-rpc_tweaks.dif=
 +
> xfs-1.1-2.4.18-all.patch.
>
> ("-", above, meaning 'patch -R')
>
> And:
>
> kernel-2.4.9-13SGI_XFS_1.0.2, which is a Red Hat 2.4.9 kernel with XFS
> v1.0.2 patches (built by SGI folks).  I can get you the appropriate pat=
ches
> from their patch set,  if you want.
>
> The server system is the 1st kernel described above.

Are you able to reproduce it on a non-XFS server?

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
