Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33647 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933212Ab1JaSQl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 14:16:41 -0400
MIME-Version: 1.0
In-Reply-To: <1320083034.4714.24.camel@lade.trondhjem.org>
References: <1319798192.26450.1.camel@localhost.localdomain>
	<1320074323.4714.2.camel@lade.trondhjem.org>
	<CADZ9YHhq91+Td03OjWbX0rwHwb6Y7QhicsuDqqAUSy2O8=05BA@mail.gmail.com>
	<1320083034.4714.24.camel@lade.trondhjem.org>
Date: Tue, 1 Nov 2011 00:16:40 +0600
Message-ID: <CADZ9YHgR=WHzCfJf7_T_WjHJJHzOnWZsM2bWSACwLHEcHy+h-g@mail.gmail.com>
Subject: Re: [PATCH] nfs: Fix unused variable warning.
From: Rakib Mullick <rakib.mullick@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 31, 2011 at 11:43 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2011-10-31 at 23:12 +0600, Rakib Mullick wrote:
>> On Mon, Oct 31, 2011 at 9:18 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Fri, 2011-10-28 at 16:36 +0600, Rakib Mullick wrote:
>> +                             data->inode->nfs_client->cl_hostname,
>                                 ^^^^^^^^^^^^
> NFS_SERVER(data->inode)->nfs_client....

Opss. Sorry, should've more careful, rather doing it quickly :(.
data->inode has nothing inside named nfs_client, but didn't even
complain. I'll resend it.

Anyway, I found the two following warning in nfs/file.c

fs/nfs/file.c: In function ‘nfs_file_release’:
fs/nfs/file.c:140:17: warning: unused variable ‘dentry’
fs/nfs/file.c: In function ‘nfs_file_read’:
fs/nfs/file.c:237:9: warning: unused variable ‘count’

I'm wanting to send one patch to cleanup all these unused variable
issues. Shall I? Or, should I send separate patches?

Thanks,
Rakib
