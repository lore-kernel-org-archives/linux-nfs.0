From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 02/15] libnfs.a: Allow multiple RPC listeners to share
 listener port number
Date: Wed, 13 Oct 2010 10:17:05 -0400
Message-ID: <4CB5BF61.9090607@RedHat.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000421.6667.60700.stgit@ellison.1015granger.net> <20101011002022.GB25663@merit.edu> <4CB30FA9.8020308@RedHat.com> <F750C283-3965-4953-9938-CF049FB914A7@oracle.com> <20101011200017.GA2451@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab0JMORM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 10:17:12 -0400
In-Reply-To: <20101011200017.GA2451-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/2010 04:00 PM, Jim Rees wrote:
> Chuck Lever wrote:
> 
>   >> It bothers me that there are two separate code paths in two separate
>   >> libraries for these two nearly identical cases.
>   
>   Are there?  Where's the other one?
>   
>   The two implementations I'm aware of are both in libnfs.a.  One is for
>   legacy RPC, and the other is for TI-RPC, and they both reside in
>   support/nfs/ (and thus in libnfs.a, which is shared by the daemons in
>   nfs-utils).  What am I missing?
> 
> Your svc_create_sock() duplicates code in svc_tli_create(), including the
> calls to socket(), bind(), and listen().
> 
> I'll buy your argument that we shouldn't change the tirpc api and that
> REUSEADDR is only half the fix.  But it still bothers me.
I agree that adding the use of REUSEADDR to the libtirpc API is
probably not way to go... So I'll take the patch as is..

steved.
