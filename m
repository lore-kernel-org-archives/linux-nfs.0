Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:45068 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756420AbeARO0Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jan 2018 09:26:25 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] Remove unneeded reference to nfsidmap_internal.h
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1516267701.3594.11.camel@redhat.com>
Date: Thu, 18 Jan 2018 09:26:16 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DEE6E104-FDC6-4BB2-9B82-8E0BE73DD0FE@oracle.com>
References: <20180117221020.11056.59627.stgit@manet.1015granger.net>
 <1516267701.3594.11.camel@redhat.com>
To: Justin Mitchell <jumitche@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 18, 2018, at 4:28 AM, Justin Mitchell <jumitche@redhat.com> wrote:
> 
> On Wed, 2018-01-17 at 17:10 -0500, Chuck Lever wrote:
>> This file is not part of "git clone" and is not #included from any
>> C file.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> support/nfsidmap/Makefile.am |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> Hey Steve-
>> 
>> I don't see nfsidmap_internal.h anywhere.  Wondering if I missed
>> something?
> 
> It was removed as part of my ABI cleanup (commit f080188e) to stop
> libnfsidmap from leaking all sorts of private symbols. 
> 
> Some of it went to libnfsidmap_plugin.h and some to
> libnfsidmap_private.h
> 
> Some external packages which offered libnfsidmap plugins were using
> these undocumented symbols by copying libnfsidmap_internal.h, so i
> reworked the neccessary parts into an API as libnfsidmap_plugin.h and
> hid the rest. 
> 
> I clearly missed this reference to the file as it didn't generate any
> warnings for me, sorry about that.

No apologies needed. Are you confirming that this clean up is OK?
Can I get an amen? (I mean, can I get a Reviewed-by?)


--
Chuck Lever



