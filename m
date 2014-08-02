Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:48633 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614AbaHBNL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Aug 2014 09:11:26 -0400
Received: by mail-vc0-f169.google.com with SMTP id le20so8348594vcb.14
        for <linux-nfs@vger.kernel.org>; Sat, 02 Aug 2014 06:11:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53DCBFDB.5060808@gmail.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
	<1406684083-19736-32-git-send-email-jlayton@primarydata.com>
	<53DCBFDB.5060808@gmail.com>
Date: Sat, 2 Aug 2014 09:11:25 -0400
Message-ID: <CAHQdGtTGNZsqZTCQhUboG1kE+bzb7p3K+5BxmusFG+qWMrVJzg@mail.gmail.com>
Subject: Re: [PATCH v3 31/38] nfsd: Move the open owner hash table into struct nfs4_client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Jeff Layton <jlayton@primarydata.com>, Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 2, 2014 at 6:39 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> On 7/30/2014 09:34, Jeff Layton wrote:
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>
>> Preparation for removing the client_mutex.
>>
>> Convert the open owner hash table into a per-client table and protect it
>> using the nfs4_client->cl_lock spin lock.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfsd/netns.h     |   1 -
>>  fs/nfsd/nfs4state.c | 187 ++++++++++++++++++++++++----------------------------
>>  fs/nfsd/state.h     |   1 +
>>  3 files changed, 86 insertions(+), 103 deletions(-)
>>
>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>> index a71d14413d39..e1f479c162b5 100644
>> --- a/fs/nfsd/netns.h
>> +++ b/fs/nfsd/netns.h
>> @@ -63,7 +63,6 @@ struct nfsd_net {
>>       struct rb_root conf_name_tree;
>>       struct list_head *unconf_id_hashtbl;
>>       struct rb_root unconf_name_tree;
>> -     struct list_head *ownerstr_hashtbl;
>
> I send a patch "NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"" before,
> http://comments.gmane.org/gmane.linux.nfs/64382
>
> nfsd needs the hashtbl to find the lockowner for locking by owner from
> fl->fl_owner stored in struct file_lock, but without nfs_client.

Why? We're not currently doing that.

> If moving the hashtbl to nfs_client, it's hard to finding the lockowner for locking.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
