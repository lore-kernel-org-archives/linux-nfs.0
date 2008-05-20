From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 8/8] SUNRPC: Display symbolic function addresses in
	rpc_show_tasks
Date: Tue, 20 May 2008 17:42:25 -0400
Message-ID: <1211319745.574.10.camel@localhost>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
	 <20080520203018.3851.21166.stgit@ellison.1015granger.net>
	 <1211317892.26809.8.camel@localhost>
	 <3F88B3F3-1820-4C6D-BE3F-533207747FBF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24036 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758873AbYETVm2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 17:42:28 -0400
In-Reply-To: <3F88B3F3-1820-4C6D-BE3F-533207747FBF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 17:37 -0400, Chuck Lever wrote:

> Except when you don't have access to the kernel image and modules  
> where the dump was generated.  Why would I want to run a script to do  
> this, when Oops output already displays symbolic function addresses in  
> a callback trace?

If you can generate the names in the same way that the Oops output does
(i.e. without having to maintain a table of function names), then I
withdraw my opposition.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
