Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:37570 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbbBZXGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 18:06:44 -0500
Received: by mail-vc0-f174.google.com with SMTP id id10so5211333vcb.5
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 15:06:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1DD59CAE-F2C8-45D3-9613-908064D8E476@oracle.com>
References: <1424914057.41161.8.camel@primarydata.com>
	<1DA1252F-8D1D-4A77-BF8B-51B8AD30975A@oracle.com>
	<CAHQdGtRAYQu8yaXORseCquO9JyWfXhkYYVx4MhM-sZXDChWiGg@mail.gmail.com>
	<1DD59CAE-F2C8-45D3-9613-908064D8E476@oracle.com>
Date: Thu, 26 Feb 2015 18:06:43 -0500
Message-ID: <CAHQdGtTibveUPBVD1n_4zMSRfGS2FAt3_oNfUdZjH=uvzXL-Yg@mail.gmail.com>
Subject: Re: fsx size error (was: File Read Returns Non-existent Null Bytes)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 26, 2015 at 2:00 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> The alternative would be to add a "barrier" operation to allow the
>> setattr code to wait for all RPC calls before ours to complete (it
>> would have to wait not just for READ, but also GETATTR and all other
>> operations to the file). We could do that too.
>
> Yes. A barrier is usually heavyweight, though. And I thought there
> was some exclusion between GETATTR and SETATTR, so forcing an
> inode revalidation should work too? Or would that result in an
> unneeded data cache invalidation?
>

I found a better solution, I think. Please see the 5 patches I just sent out.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
