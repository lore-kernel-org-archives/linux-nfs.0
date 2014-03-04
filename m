Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:39183 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaCDSJk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 13:09:40 -0500
Received: by mail-ie0-f179.google.com with SMTP id lx4so2696843iec.24
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 10:09:40 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 0/4] NFSv4 fix nfs4_stateid_is_current processing
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1393954269-3974-1-git-send-email-andros@netapp.com>
Date: Tue, 4 Mar 2014 13:09:37 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <FE2FF2AA-62E5-4D8C-9025-D6C648385FFA@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
To: Adamson William Andros <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 4, 2014, at 12:31, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> This is an expanded version of the "NFSv4 always compare stateids in nfs4_stateid_is_current" patch I sent on Feb 27.
> 
> Found at Connectathon 2014 and NetApp internal testing.
> 
> nfs4_stateid_is_current is used on the NFSv4 I/O path to determine if a
> stateid has changed. The idea is that if there is a stateid expire error
> such as NFS4ERR_BAD_STATEID and the stateid used that induced the error has
> changed, then we can just resend the RPC from the call prepare state with
> the changed stateid instead of kicking off recovery as the changed stateid
> indicates it already had been recovered.
> 
> This patch set fixes a false positive that resulted in an NFS4ERR_BAD_STATEID
> infinite loop. Trond pointed out that the nfs4_select_rw_stateid -EIO error
> is special in that it indicates a lost lock.
> 
> As I examined the use of nfs4_select_rw_stateid, I addressed some other errors
> in the use of nfs4_set_rw_stateid and friends in setattr and filelayout
> prepare functions.
> 
> Just tested with connectathon tests. Will test more once I'm back in town...

One question:

Do we need the EWOULDBLOCK case at all in nfs4_copy_lock_stateid/nfs4_copy_open_stateid? Looking at the code, it seems particularly redundant for the case of NFSv4.1, where we set the seqid to ‘0’. Given that we do the nfs4_stateid_is_current() test, it seems unnecessary in the case of NFSv4.0 too...

So, how about just throwing out the EWOULDBLOCK returns, then keeping nfs4_stateid_is_current() as it is, fixing up _nfs4_do_setattr to only deal with the -EIO case, and then fixing up the file layout uses of nfs4_select_rw_stateid() to check the return values?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

