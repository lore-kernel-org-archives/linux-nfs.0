From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 server: lockd hangs
Date: Wed, 18 Oct 2006 14:20:57 -0400
Message-ID: <1161195658.6095.88.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0610181118190.8690-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaG2Y-00084k-1e
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:21:18 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaG2W-0002UG-Tt
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:21:19 -0700
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <Pine.LNX.4.44.0610181118190.8690-100000@lothlorien.local>
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

On Wed, 2006-10-18 at 11:30 +0200, Helge Bahmann wrote:
> Hello,
> 
> I have problems with lockd on an NFS server (stock 2.6.17 kernel); I have
> no easy test case to reproduce the problem, but after one to two weeks of
> uptime the lockd process is simply stuck. It fails to shutdown
> ("lockd_down: lockd failed to exit"; afterwards the "[lockd]" thread is
> still around and stuck in D state) and is otherwise unresponsive. No other
> kernel messages are logged.
> 
> Only full reboot solves the problem.
> 
> Can you tell me
> - if there is a known lockd problem? I could not find anything in the
> archives, but maybe I have missed something
> - if it may be a file-system-specific problem (reiserfs in the present
> case)?
> - what else can I do to provide more useful diagnostics?

There is a known deadlock in lockd for stock 2.6.17. See the fix at

  http://client.linux-nfs.org/Linux-2.6.x/2.6.18-rc4/linux-2.6.18-011-fix_nlm_traverse_files_deadlock.dif


This patch will be included in the next stable release for 2.6.17.

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
