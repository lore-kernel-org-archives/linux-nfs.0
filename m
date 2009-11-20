From: Joshua Baker-LePain <jlb17-4+jYJfmkT58@public.gmane.org>
Subject: Re: [NFS] simple NFSv4 setup
Date: Fri, 20 Nov 2009 18:26:22 -0500 (EST)
Message-ID: <alpine.LRH.2.00.0911201825340.8086@hogwarts.egr.duke.edu>
References: <alpine.LRH.2.00.0911191507420.8086@hogwarts.egr.duke.edu>
	<20091120181935.GB8841@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57542 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752967AbZKTX0z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 18:26:55 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NBcsW-0000Uj-8I
	for linux-nfs@vger.kernel.org; Sat, 21 Nov 2009 10:27:00 +1100
In-Reply-To: <20091120181935.GB8841@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 20 Nov 2009 at 1:19pm, J. Bruce Fields wrote

> I'm assuming /export and /export/qb3 are on the same filesystem?
>
> In that case, adding a mountpoint at /export/qb3:
>
> 	mount --bind /export/qb3 /export/qb3
>
> (and adding crossmnt on /export) will probably work around the problem.
>
> As stated elsewhere, this isn't really secure: an attacker with access
> to the network will probably still be able to write to /export/.  If
> that's a problem, then you need qb3 to really be its own filesystem.

This is exactly what I needed -- thanks for the pointer.  I went with the 
2nd option, and it works as it should.  Thanks again.

-- 
Joshua Baker-LePain
QB3 Shared Cluster Sysadmin
UCSF

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

