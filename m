From: Dan Yocum <yocum@fnal.gov>
Subject: Re: Null characters in files on NFS mounted volume....
Date: Mon, 13 May 2002 11:54:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CDFEFB4.D22CF52D@fnal.gov>
References: <3CDFCE9F.2BE050D5@fnal.gov> <shswuu8ytk4.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177J5R-00071X-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 09:54:13 -0700
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0GW200KPX6YCAX@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Mon, 13 May 2002 11:54:12 -0500 (CDT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond,

Nothing special in /var/log/messages on either the client or server that
would help in debugging the problem, unfortunately.

I'm seeing the problem on these 2 client systems:

vanilla 2.4.18 + linux-2.4.18-NFS_ALL.dif - linux-2.4.18-rpc_tweaks.dif +
xfs-1.1-2.4.18-all.patch.

("-", above, meaning 'patch -R')

And:

kernel-2.4.9-13SGI_XFS_1.0.2, which is a Red Hat 2.4.9 kernel with XFS
v1.0.2 patches (built by SGI folks).  I can get you the appropriate patches
from their patch set,  if you want.

The server system is the 1st kernel described above.

The files are FITS files (text header tables, followed by binary data).  The
data was written once to disk and is read by many clients.

If I could reproduce the problem at will, I'd try a generic kernel, but it's
intermittent at best, and we need the patches to access the IRIX servers. 
:-(

When it happens again, I'll do some more debugging on the problem.

Thanks,
Dan



Trond Myklebust wrote:
> 
> >>>>> " " == Dan Yocum <yocum@fnal.gov> writes:
> 
>      > Hi all, I've got a "New and Exciting" <tm> bug using 2.4.18
>      > with Trond's client patches (sans the rpc_tweaks dif), but I'm
>      > not sure it's a client side problem.
> 
>      > This is an intermitent problem: When attempting to read a file
>      > (any file) on an NFS mounted volume, there appear to be "holes"
>      > in the file filled with ASCII NULL characters.  Reading the
>      > file on the local machines shows no such holes, and other NFS
>      > clients don't see the holes, either.  A simple umount/remount
>      > solves the problem.
> 
> Any details?
> 
> Are these for instance ordinary files? Are you perhaps engaging in
> some multiple NFS client read/writes to the same file? ...  Is it tied
> to the client patches, or does it occur with stock 2.4.18 fresh off
> the l-k presses?
> 
> Cheers,
>   Trond


-- 
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
