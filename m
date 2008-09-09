From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Tue, 09 Sep 2008 08:09:28 -0700
Message-ID: <m18wu1nyon.fsf@frodo.ebiederm.org>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57659 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbYIIPO6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2008 11:14:58 -0400
In-Reply-To: <20080909124311.GA10053@us.ibm.com> (Serge E. Hallyn's message of
	"Tue, 9 Sep 2008 07:43:11 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Thanks, Cedric.  Eric is probably right about the long-term fix, but
> yeah it might take a while to properly wade through the sunrpc and nfs
> layers to store the nodename at nfs mount time, and in the meantime this
> fixes a real oops.

A very esoteric oops that hasn't shown up for two years.
Please let's look at this and see what it would take to fix this
properly.

What are we trying to achieve by reading utsname?

Eric

