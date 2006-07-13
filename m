From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: bug in linux mount? (says NetApp)
Date: Thu, 13 Jul 2006 09:37:51 -0400
Message-ID: <1152797871.5678.51.camel@lade.trondhjem.org>
References: <A0674ED473ECE741B47C065D2FB6DC2008A785@BP1XEUEX029-C.bp1.ad.bp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, gregory.baker@amd.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G11OQ-0005zh-K4
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 06:38:14 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G11OP-0008SQ-M1
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 06:38:15 -0700
To: "Murata, Dennis W (SAIC)" <dennis.murata@bp.com>
In-Reply-To: <A0674ED473ECE741B47C065D2FB6DC2008A785@BP1XEUEX029-C.bp1.ad.bp.com>
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

On Wed, 2006-07-12 at 21:23 +0100, Murata, Dennis W (SAIC) wrote:
> The entry from /proc/mounts does not list the values for timeo or
> retrans:
> 
> nfsserver:/vol/vol1/home/foo /home/foo nfs
> rw,nosuid,v3,rsize=32768,wsize=32768,hard,intr,tcp,lock,addr=nfsserver 0
> 0
> 
> Is this normal?

Yes. If you have a recent kernel (2.6.17 or newer), I believe you should
be able to check the full mount options using /proc/self/mountstats

Cheers,
  Trond



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
