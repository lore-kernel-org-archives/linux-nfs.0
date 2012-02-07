Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39756 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424Ab2BGSl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2012 13:41:56 -0500
Message-ID: <4F317064.8020509@panasas.com>
Date: Tue, 7 Feb 2012 20:41:40 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Weston Andros Adamson <dros@netapp.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: add mount options 'v4.0' and 'v4.1'
References: <1328633351-1741-1-git-send-email-dros@netapp.com> <A5356E85-1E22-4C4C-A30C-58A912AE3C9F@oracle.com> <4F316BC4.4030504@panasas.com> <38718BB0-83D0-42FF-8E86-E88299B54267@oracle.com>
In-Reply-To: <38718BB0-83D0-42FF-8E86-E88299B54267@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/2012 08:37 PM, Chuck Lever wrote:
>> If we are at it can we also have a "this-version-only" option which
>> disables "auto-negotation"
> 
> That's what "vers=" already does. If "vers=" is specified, the mount
> point uses that version, or the mount operation fails if the server
> or client doesn't support the requested version. There is no version
> negotiation when "vers=" is specified.

I didn't know that I thought vers=4 will also try 3 if not supported by
Server

> 
> What did you have in mind?
> 

You are right I was thinking about if 4.1 I do not want 4.0

Thanks
Boaz
