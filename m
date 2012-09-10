Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37996 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2IJVD7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2012 17:03:59 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, Jeff Layton <jlayton@redhat.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered
 writes
Date: Mon, 10 Sep 2012 21:03:51 +0000
Message-ID: <7851A663D3BF5E41B9E166C2C7A42145102B312E@SACEXCMBX02-PRD.hq.netapp.com>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
 <20120910145732.4d800f5b@corrin.poochiereds.net>
 <20120910195650.GA3095@umich.edu>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908F97C34@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F97C34@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff, Jim, Trond - Thanks for all the comments.  I'm looking again at the code and will incorporate your suggestions and do some more testing. Should have results and a modified patch set tomorrow.

-->Andy

On Sep 10, 2012, at 4:14 PM, Myklebust, Trond wrote:

> On Mon, 2012-09-10 at 15:56 -0400, Jim Rees wrote:
>> Jeff Layton wrote:
>> 
>>  My only concern is this behavior described in the last patch:
>> 
>>  "If the buffered WRITE is using a credential key that will expire
>>  within low watermark seconds, fail the WRITE in nfs_write_begin
>>  _before_ the WRITE is buffered and return -EACCES to the application."
>> 
>>  Shouldn't rejecting the write attempt be the purview of the server?
>> 
>>  It seems to me that we'd be best off just switching to synchronous
>>  writes when we start approaching credential expiration, and letting the
>>  server handle the case where the credential expires.
>> 
>>  It seems to me that the client should just be in the business of
>>  recognizing when the credential might be about to expire and attempt to
>>  ensure that we don't end up with a bunch of buffered data in that case.
>> 
>> I don't like it.  It's easy to understand why writes might fail if the creds
>> are getting stale.  It's not so easy to understand why client behavior
>> changes in a subtle way, with performance implications.
> 
> We don't know that the creds are stale. We just know that the GSS
> session is about to expire.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

