Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34310 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261Ab3JXPxl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 11:53:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Simo Sorce <simo@redhat.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 15:53:38 +0000
Message-ID: <1382630015.6430.6.camel@leira.trondhjem.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
	 <1382627225.899.76.camel@willson.li.ssimo.org>
	 <1382627496.6430.2.camel@leira.trondhjem.org>
	 <1382627770.899.79.camel@willson.li.ssimo.org>
	 <20131024112319.7ad9fd27@tlielax.poochiereds.net>
In-Reply-To: <20131024112319.7ad9fd27@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 11:23 -0400, Jeff Layton wrote:
+AD4- On Thu, 24 Oct 2013 11:16:10 -0400
+AD4- Simo Sorce +ADw-simo+AEA-redhat.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Thu, 2013-10-24 at 15:11 +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4- On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Because the filesystem can do that when multiple applications are
+AD4- +AD4- +AD4- +AD4- involved without having to change them all to talk to each other and
+AD4- +AD4- +AD4- +AD4- invent custom protocol all the time just to keep some additional
+AD4- +AD4- +AD4- +AD4- metadata associated to a file..
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- It's still a custom protocol. The applications need to agree on a data
+AD4- +AD4- +AD4- format and store it somewhere. The portable way to do this is to write
+AD4- +AD4- +AD4- an application library that they can link to.
+AD4- +AD4- 
+AD4- +AD4- Perhaps I was unclear, you are never going to see that custom library
+AD4- +AD4- linked into the 'mv' command.
+AD4- +AD4- 
+AD4- +AD4- So your approach makes little sense if the object is to maintain data
+AD4- +AD4- coherent when people need to handle files from random applications and
+AD4- +AD4- scripts and general system maintenance.
+AD4- +AD4- 
+AD4- +AD4- The data may be relevant only to a specific application.
+AD4- +AD4- 
+AD4- +AD4- I am not saying you +ACo-have+ACo- to implement xattrs support, just saying that
+AD4- +AD4- it is not a mere 'applications should synchronize data themselves'
+AD4- +AD4- problem.
+AD4- +AD4- 
+AD4- 
+AD4- I think the real solution if people need this is to lead an effort to
+AD4- put xattrs into the spec. I think there is still time to get new
+AD4- features into v4.3 if someone wants to champion it...
+AD4- 

How would that help? Witness Oracle's success with named attributes,
which are +AF8-also+AF8- a non-standard filesystem feature that was hastily
pushed into the NFSv4 spec.

If you really need this for use by applications (as opposed to by
sysadmins - see labeled NFS), then get the functionality into POSIX
first, then add it to the NFS spec.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
