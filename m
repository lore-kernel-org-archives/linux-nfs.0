Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f173.google.com ([74.125.82.173]:64104 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab3JANb1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 09:31:27 -0400
Received: by mail-we0-f173.google.com with SMTP id w62so7354652wes.32
        for <linux-nfs@vger.kernel.org>; Tue, 01 Oct 2013 06:31:25 -0700 (PDT)
Message-ID: <524ACEA9.1040304@primarydata.com>
Date: Tue, 01 Oct 2013 16:31:21 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
References: <52447EA0.7070004@primarydata.com> <1380220968-14669-1-git-send-email-bhalevy@primarydata.com> <20130929121903.GF21083@infradead.org>
In-Reply-To: <20130929121903.GF21083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:19, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:42:48PM -0400, Benny Halevy wrote:
>> we don't want to hold the state_lock while the file system may block
> 
> Needs a much beter changelog:
> 
>  - why don't you want to hold it
>  - why you think the new version is safe and performs fine.

OK.

So the reason not to hold it is that the nfs state lock is global to the
server and blocks all state modifying operations such as:
open, close, lock, clientid, session operations, etc.

It is safe to release the state lock from the pnfs call sites
on the resource dereferencing path as:
a. The file system is not expected to recurs back into the knfsd code
while holding the state lock.
b. The high level operation is already done at this point and it is not
required to hold the state lock any further.

Note that there are more call sites of put_nfs4_file in nfs4state.c
that need further analysis and move to put_nfs4_file_locked where possible.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
