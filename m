Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:56354 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbcLFGq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 01:46:56 -0500
Subject: Re: Revalidate failure leads to unmount
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20161206061747.GN1555@ZenIV.linux.org.uk>
Date: Tue, 6 Dec 2016 01:46:47 -0500
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Message-Id: <A7250E83-29DF-4976-91A3-101D2A3438C5@linuxhacker.ru>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru> <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru> <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru> <20161206020059.GL1555@ZenIV.linux.org.uk> <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru> <20161206050254.GM1555@ZenIV.linux.org.uk> <D061B89E-EFC7-49F8-86C0-C60FDF269D3C@linuxhacker.ru> <20161206061747.GN1555@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 6, 2016, at 1:17 AM, Al Viro wrote:

> On Tue, Dec 06, 2016 at 12:45:11AM -0500, Oleg Drokin wrote:
> 
>> Well, certainly if d_splice_alias was working like that so that even non-directory
>> dentry would find an alias (not necessarily unhashed even) for that same inode and use that instead, that would make ll_splice_alias/ll_find_alias unnecessary.
>> 
>> We still retain the weird d_compare() that rejects otherwise perfectly valid aliases
>> if the lock guarding them is gone, triggering relookup (and necessiating the
>> above logic to pick up just rejected alias again now that we have the lock again).
> 
> Why not have ->d_revalidate() kick them, instead?  _IF_ we have a way to
> do unhash-and-trigger-lookup that way, do you really need those games with
> ->d_compare()?

The comment there says:
 * This avoids a race where ll_lookup_it() instantiates a dentry, but we get
 * an AST before calling d_revalidate_it().  The dentry still exists (marked
 * INVALID) so d_lookup() matches it, but we have no lock on it (so
 * lock_match() fails) and we spin around real_lookup().

and indeed I seem to have a memory of some code that did lookup followed
by revalidate (though checking commit history, that was a long time ago).
I checked and apparently now lookup_real() does not do any revalidation and
neither does its caller.

So assuming lookup no longer is followed by mandatory revalidate, we probably
can just move the lock check to the start of revalidate, I'll try that tomorrow.


