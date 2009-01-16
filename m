From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Where is the nfs-utils source code repository?
Date: Fri, 16 Jan 2009 14:34:43 -0500
Message-ID: <1232134483.6941.17.camel@heimdal.trondhjem.org>
References: <4970D8AB.60409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57959 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbZAPTes (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 14:34:48 -0500
In-Reply-To: <4970D8AB.60409@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linux-nfs.org is likely to be down for one or two more days. A couple of
machines at the site that is hosting it were recently hacked, and so the
entire subnet had to be taken offline for the duration of the cleanup.

I'll send out an email as soon as we have full web and git repository
service up and running.

Cheers
  Trond

On Fri, 2009-01-16 at 10:57 -0800, Ben Greear wrote:
> I'm trying to do some development to allow binding to a local
> IP address when mounting an NFS file server, but I cannot find
> an nfs-utils git repository that works.  Based on the 1.1.4 package
> README, this should work:
> 
> git clone git://linux-nfs.org:/nfs-utils
> 
> 
> But, no luck:
> 
> [greearb@fs2 tmp]$ git clone git://linux-nfs.org/nfs-utils
> Initialized empty Git repository in /home/greearb/tmp/nfs-utils/.git/
> fatal: The remote end hung up unexpectedly
> fetch-pack from 'git://linux-nfs.org/nfs-utils' failed.
> 
> Anyone know of a working git repo for the latest nfs-utils
> package?
> 
> Thanks,
> Ben
> 

