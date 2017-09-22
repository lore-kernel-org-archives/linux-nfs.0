Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbdIVTO6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Sep 2017 15:14:58 -0400
Date: Fri, 22 Sep 2017 15:14:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170922191457.GA4786@fieldses.org>
References: <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170922115524.GN12725@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 22, 2017 at 12:55:24PM +0100, Daniel P. Berrange wrote:
> On Fri, Sep 22, 2017 at 07:43:39AM -0400, Chuck Lever wrote:
> > If firewall configuration is a chronic problem, let's address that.
> 
> This just isn't practical in the general case. Even on a single Linux OS
> distro there are multiple ways to manage firewalls (Fedora as a static
> init script, or firewalld, and many users invent their own personal way
> of doing it). There are countless other OS, many closed source with 3rd
> party firewall products in use. And then there are the firewall policies
> defined by organization's IT departments that mandate particular ways of
> doing things with layers of approval to go through to get changes made.
> 
> IOW, while improving firewall configuraiton is a worthy goal, it isn't
> a substitute for host<->guest file system sharing over a non-network
> based transport. 

I guess what's confusing to me is you're already depending on a ton of
assumptions about the guest:

	- it has to be running a recent kernel with NFS/VSOCK support.
	- it has to have all the nfs-utils userspace stuff, a
	  /usr/bin/mount that works the way you expect, and an
	  /etc/nfsmount.conf that doesn't have any odd options.
	- it has to have a suitable mount point somewhere that the admin
	  knows about.
	- probably lots of other stuff

It's odd that the firewall configuration is the one step too far.

As long as we've got all these requirements on guests, is there no
chance we could add a requirement like "if you want shared filesystems,
outbound tcp connections to port 2049 must be permitted on interface
vhost0".  ?

--b.
