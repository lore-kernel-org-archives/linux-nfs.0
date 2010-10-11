From: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH 02/15] libnfs.a: Allow multiple RPC listeners to share
 listener port number
Date: Mon, 11 Oct 2010 16:00:17 -0400
Message-ID: <20101011200017.GA2451@merit.edu>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
 <20101011000421.6667.60700.stgit@ellison.1015granger.net>
 <20101011002022.GB25663@merit.edu>
 <4CB30FA9.8020308@RedHat.com>
 <F750C283-3965-4953-9938-CF049FB914A7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:49996 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755105Ab0JKUAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 16:00:18 -0400
In-Reply-To: <F750C283-3965-4953-9938-CF049FB914A7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  >> It bothers me that there are two separate code paths in two separate
  >> libraries for these two nearly identical cases.
  
  Are there?  Where's the other one?
  
  The two implementations I'm aware of are both in libnfs.a.  One is for
  legacy RPC, and the other is for TI-RPC, and they both reside in
  support/nfs/ (and thus in libnfs.a, which is shared by the daemons in
  nfs-utils).  What am I missing?

Your svc_create_sock() duplicates code in svc_tli_create(), including the
calls to socket(), bind(), and listen().

I'll buy your argument that we shouldn't change the tirpc api and that
REUSEADDR is only half the fix.  But it still bothers me.
