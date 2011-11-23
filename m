Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092Ab1KWUdj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 15:33:39 -0500
Date: Wed, 23 Nov 2011 15:33:39 -0500
To: Todd Freeman <freeman@andrews.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Updated files desync and become unlinked
Message-ID: <20111123203339.GB1044@fieldses.org>
References: <4EC53D15.3020801@andrews.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC53D15.3020801@andrews.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2011 at 11:57:57AM -0500, Todd Freeman wrote:
> Good day all...
> 
> This may (very likely) be me just misunderstanding a "feature" of
> NFS...  but I have a VERY odd behaviour pattern.
> 
> We update a set of perl modules on an NFS client (svn update to grab
> new files) we then ssh to another client and restart our apache
> server there and go along our merry way.
> We noticed that the apache server would fairly consistently have an
> old version of the file running and continue running with it until a
> new child started and reread the file (minutes later).

Restarting the apache server should mean apache re-opens the module,
which should be enough for NFS's close-to-open semantics.

If you're exporting ext3 on the server, it could be a time-resolution
problem (ext3 has 1-second resolution timestamps), though I wouldn't
expect that problem to reproduce so quickly.

If you're using NFSv4, it could be a delegation bug; run

	echo 0 >/proc/sys/fs/leases-enable
	
and restart the nfs server to turn them off.

--b.

> 
> In debugging this we changed the module so that it checks its .pm
> file with a stat call to see how things are going. The data that we
> got from the stat reflected that the file was still old. We noticed
> that 'ls -al /the/directory/with/the/module/ ' would "fix" the
> desync... but that 'ls -al /the/directory/with/the/module/Module.pm'
> would not. We also noticed that an ls of the file in question would
> show the link count as 0 until it got "fixed", once fixed the link
> count was 1 again.
> 
> Am I missing a mount option.. or is there some way around this
> "feature" without doing and ls -alR of the whole thing to make sure
> all the modules are up to date?
> 
> My system info:
> Ubuntu 10.10 server
> 2.6.35-30-server #60-Ubuntu SMP Mon Sep 19 21:00:00 UTC 2011 x86_64
> GNU/Linux
> 
> nfs-common 1:1.2.2-1ubuntu1.1
> 
> Thanks for any help you have to offer.
> 
> --
> Todd
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
