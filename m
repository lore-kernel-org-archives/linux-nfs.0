Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35894 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcLFGRt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2016 01:17:49 -0500
Date: Tue, 6 Dec 2016 06:17:47 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: Revalidate failure leads to unmount
Message-ID: <20161206061747.GN1555@ZenIV.linux.org.uk>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru>
 <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru>
 <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru>
 <20161206020059.GL1555@ZenIV.linux.org.uk>
 <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru>
 <20161206050254.GM1555@ZenIV.linux.org.uk>
 <D061B89E-EFC7-49F8-86C0-C60FDF269D3C@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D061B89E-EFC7-49F8-86C0-C60FDF269D3C@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 06, 2016 at 12:45:11AM -0500, Oleg Drokin wrote:

> Well, certainly if d_splice_alias was working like that so that even non-directory
> dentry would find an alias (not necessarily unhashed even) for that same inode and use that instead, that would make ll_splice_alias/ll_find_alias unnecessary.
> 
> We still retain the weird d_compare() that rejects otherwise perfectly valid aliases
> if the lock guarding them is gone, triggering relookup (and necessiating the
> above logic to pick up just rejected alias again now that we have the lock again).

Why not have ->d_revalidate() kick them, instead?  _IF_ we have a way to
do unhash-and-trigger-lookup that way, do you really need those games with
->d_compare()?
