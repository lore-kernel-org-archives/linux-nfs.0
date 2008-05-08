From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] nfs-utils gssd
Date: Thu, 08 May 2008 04:58:04 -0400
Message-ID: <4822C09C.2080402@RedHat.com>
References: <20080501133455.28884.4768.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367AbYEHJDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 05:03:25 -0400
In-Reply-To: <20080501133455.28884.4768.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Coffman wrote:
> Hi Steve,
> These have all been sent before, with various levels of formality,
> but haven't made it into git yet.
> 
> 1) adds code to gssd to read a possible alternate port number
> from the info file.
> 
> 2) adds the "other" DES encryption types to the default list that
> can currently be negotiated.
> 
> 3) adds a utility function to retrieve the current logging
> verbosity.  (Used by the fourth patch to determine whether
> it should print certain error messages.)
> 
> 4) allows the administrator to specify multiple directories
> where gssd can look for credentials caches.
Committed... thanks... 

steved.

