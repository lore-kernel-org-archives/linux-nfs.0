Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45493 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032196AbdDZWvh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 18:51:37 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: rdma connection close/reopen every 5 mins
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <odr81f$k4m$1@blaine.gmane.org>
Date: Wed, 26 Apr 2017 15:52:50 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D82E4998-B2C0-42E5-B51B-4DA13ACB5BB2@oracle.com>
References: <odql2m$vup$1@blaine.gmane.org> <97258237-282D-4A72-9AEE-BC1B82DF8E1C@oracle.com> <odr81f$k4m$1@blaine.gmane.org>
To: scar <scar@drigon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2017, at 3:47 PM, scar <scar@drigon.com> wrote:
> 
> Chuck Lever wrote on 04/26/2017 01:32 PM:
>> If it's every 5 minutes, that's probably the RPC idle timeout
>> that is closing the connection.
>> 
>> So this should be entirely harmless.
> 
> Yes so far it seems harmless, but it is annoying and fills up the log with spam, plus it's not something I see when using NFS/TCP.

That's correct, NFS/TCP does not have the "connected / closed"
messages, but the idle timeout behavior is the exactly the same.

I tried to remove those messages a few years ago and was told
to go pound sand.

The best you can do is create a mechanism to access a file on
those mount points more frequently than the idle timeout. That
should prevent the connection from closing.


--
Chuck Lever



