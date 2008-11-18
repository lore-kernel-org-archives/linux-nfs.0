From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] First subset of nfs-utils IPv6 support
Date: Tue, 18 Nov 2008 13:05:24 -0500
Message-ID: <492303E4.2060101@RedHat.com>
References: <20081029172134.19663.13493.stgit@ingres.1015granger.net> <4921DE84.2060607@RedHat.com> <03F6107F-8CF2-498F-8095-FD31EA8DEBA1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35922 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbYKRSH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2008 13:07:26 -0500
In-Reply-To: <03F6107F-8CF2-498F-8095-FD31EA8DEBA1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Nov 17, 2008, at Nov 17, 2008, 4:13 PM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>> Hi Steve-
>>>
>>> I sent these out yesterday, but I haven't seen them on the list or in
>>> mail archives.  Ah.  It's because I didn't copy the list!  So, here
>>> goes.
>>>
>>> These two patches introduce a set of library functions that replace the
>>> separate AF_INET-only implementations in each component of nfs-utils
>>> (mount.nfs, showmount, sm-notify, etc) of GETPORT with a common shared
>>> implementation that supports both PMAP_GETPORT and RPCB_GETADDR, and
>>> both AF_INET and AF_INET6.  Subsequent patches will convert each
>>> component to use these.
>>>
>>> These should build and operate correctly on systems without any trace
>>> of libtirpc libraries or headers.  On such systems, only PMAP_GETPORT
>>> and AF_INET is supported.
>>>
>>> I think these are ready to be included in nfs-utils, so let's start the
>>> review process.
>>>
>>> ---
>>>
>>> Chuck Lever (2):
>>>      nfs-utils: Introduce rpcbind client utility functions
>>>      nfs-utils: Add AF_INET6-capable API to acquire an RPC CLIENT *
>> I apologize for the delay... Both committed..
> 
> Hi Steve-
> 
> I don't see the new file support/nfs/getport.c in your tree.  This
> should have been added by commit 541bf913.
Its there now... Sorry about that...

steved.

