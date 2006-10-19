From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 server: lockd hangs
Date: Thu, 19 Oct 2006 09:30:23 -0400
Message-ID: <1161264623.28834.6.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0610190943400.12867-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaXyx-0002Nw-8r
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 06:30:47 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaXyt-000623-Np
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 06:30:48 -0700
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <Pine.LNX.4.44.0610190943400.12867-100000@lothlorien.local>
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

On Thu, 2006-10-19 at 09:56 +0200, Helge Bahmann wrote:
> Trond Myklebust wrote:
> > There is a known deadlock in lockd for stock 2.6.17. See the fix at
> >
> >   http://client.linux-nfs.org/Linux-2.6.x/2.6.18-rc4/linux-2.6.18-011-fix_nlm_traverse_files_deadlock.dif
> >
> >
> > This patch will be included in the next stable release for 2.6.17.
> 
> Okay thanks; upgraded to 2.6.18 which apparently contains the fix (and
> hopefully no regressions)

2.6.17.14 should also contain it.

> Is there also a known problem with NFSv3 file locking and sec=krb5 mounts?
> Sometimes a process on the NFS client hangs trying to lock a file which is
> definitely *not* locked on any other client -- strange thing is, it
> happens only if the same process does more than one lock/unlock cycle, and
> it only happens after multiple ticket expiries. However if it has happened
> once, it becomes quite reproducable. Rebooting the client fixes the
> problem. Rebooting the server does as well.
> 
> Is there something I could do to diagnose the problem once the problem
> starts appearing?

cat /proc/locks on both the client and server. The 5th column there
should be in the form 'device_major:device_minor:inode_number'. See if
you can find a match for the file that is not supposed to be locked.

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
