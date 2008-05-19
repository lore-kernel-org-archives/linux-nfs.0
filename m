From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 1/8] NFS: Update help text for CONFIG_NFS_FS
Date: Mon, 19 May 2008 13:09:01 -0400
Message-ID: <RTPCLUEXC1-PRDXzzAg00000113@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net>
 <20080518021614.8366.39102.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57003 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbYESRI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 13:08:58 -0400
In-Reply-To: <20080518021614.8366.39102.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
References: <20080518021241.8366.12464.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
 <20080518021614.8366.39102.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:16 PM 5/17/2008, Chuck Lever wrote:
>Clean up: refresh the help text for Kconfig items related to the NFS
>client.  Remove obsolete URLs, and make the language consistent among
>the options.

I like the patch for no other reason than (finally) getting rid
of the CODA nasty-gram:

>-	  A superior but less widely used alternative to NFS is provided by
>-	  the Coda file system; see "Coda file system support" below.

But I do have a comment - I think calling it "Sun's" protocol is unnecessary.
It's an IETF standard, and widely implemented.

>+	  Choose Y here if you want to access files residing on other
>+	  computers using Sun's Network File System protocol.  To compile
>+	  this file system support as a module, choose M here: the module
>+	  will be called nfs.


> config NFS_V3
>-	bool "Provide NFSv3 client support"
>+	bool "NFS client support for NFS version 3"

The new option says NFS twice.

> 	depends on NFS_FS
> 	help
>-	  Say Y here if you want your NFS client to be able to speak version
>-	  3 of the NFS protocol.
>+	  This option enables support for version 3 of the NFS protocol
>+	  (RFC 1813) in the kernel's NFS client.

And twice again.

> config NFS_V4
>-	bool "Provide NFSv4 client support (EXPERIMENTAL)"
>+	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
> 	depends on NFS_FS && EXPERIMENTAL

Is it necessary to say "(EXPERIMENTAL)"? There are many other kernel
options that don't, but in fact are dependent.

Tom.

