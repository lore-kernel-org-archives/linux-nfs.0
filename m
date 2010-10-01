Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:46860 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753410Ab0JAUHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 16:07:48 -0400
Date: Fri, 1 Oct 2010 16:07:47 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: Updated pNFS Developmental kernel repository
Message-ID: <20101001200747.GA4353@merit.edu>
References: <4CA5C059.6000805@RedHat.com>
 <4CA5E744.9010006@desy.de>
 <4CA63D1A.5070108@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA63D1A.5070108@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  On 10/01/2010 09:51 AM, Tigran Mkrtchyan wrote:
  > 
  > Hi Steve,
  > 
  > thanks for the builds. What I am missing is modprobe configuration file
  > which I have to add myself.
  Unfortunately yes... I have not figured out a good way to have
  the mobprobe done on the client since, in general, init scripts
  don't run on the client (with the exception of rpc.statd and rpc.gssd).
  
  I guess I could come up with an pnfs init script..but that
  seems like a bit overkill just to do a modprobe... 

I've already got an init script for the block layout client that does the
modprobe and starts the daemon.  How about we generalize it to modprobe the
other modules too, and call it the pnfs init script?
