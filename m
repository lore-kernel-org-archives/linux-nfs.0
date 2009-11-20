From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] simple NFSv4 setup
Date: Fri, 20 Nov 2009 13:19:35 -0500
Message-ID: <20091120181935.GB8841@fieldses.org>
References: <alpine.LRH.2.00.0911191507420.8086@hogwarts.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Joshua Baker-LePain <jlb17-4+jYJfmkT58@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:32962 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbZKTSTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 13:19:38 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NBY59-0007oU-7S
	for linux-nfs@vger.kernel.org; Sat, 21 Nov 2009 05:19:43 +1100
In-Reply-To: <alpine.LRH.2.00.0911191507420.8086-W36viC/h94rN/LjLm1us4tXUKCiYXWp1@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 19, 2009 at 03:11:58PM -0500, Joshua Baker-LePain wrote:
> (I've tried this on both the CentOS and RHEL5 lists, so apologies if 
> you've gotten this multiple times.)
> 
> I'm trying to setup a simple NFSv4 mount between two CentOS 5.4 x86_64 
> hosts. On the server, I have this in /etc/exports:
> 
> /export         $CLIENT(ro,fsid=0)
> /export/qb3     $CLIENT(rw,nohide)
> 
> /export is its own filesystem.  This results in the following
> 'exportfs -v' output:
> 
> /export/qb3     $CLIENT(rw,wdelay,nohide,root_squash,no_subtree_check,anonuid=65534,anongid=65534)
> /export         $CLIENT(ro,wdelay,root_squash,no_subtree_check,fsid=0,anonuid=65534,anongid=65534)
> 
> ON $CLIENT, I mount via:
> 
> mount -t nfs4 $SERVER:/qb3 /usr/local/sge62/qb3
> 
> However:
> 
> $ touch /usr/local/sge62/qb3/foo
> touch: cannot touch `/usr/local/sge62/qb3/foo': Read-only file system
> 
> I'd really rather not export the pseudo-root read-write, so how do I get 
> this working?  I've tried putting the crossmnt option on /export (with and 
> without using nohide on /export/qb3), and that doesn't help.  Any hints as 
> to what I'm doing wrong would be appreciated.  Thanks.

I'm assuming /export and /export/qb3 are on the same filesystem?

In that case, adding a mountpoint at /export/qb3:

	mount --bind /export/qb3 /export/qb3

(and adding crossmnt on /export) will probably work around the problem.

As stated elsewhere, this isn't really secure: an attacker with access
to the network will probably still be able to write to /export/.  If
that's a problem, then you need qb3 to really be its own filesystem.

--b.

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

