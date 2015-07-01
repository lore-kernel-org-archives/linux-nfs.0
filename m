Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36276 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbbGAO6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jul 2015 10:58:13 -0400
Received: by pdcu2 with SMTP id u2so27583800pdc.3
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jul 2015 07:58:12 -0700 (PDT)
Message-ID: <5593FFFB.50700@gmail.com>
Date: Wed, 01 Jul 2015 22:58:03 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 3/8] nfs: Use remove_proc_subtree() instead remove_proc_entry()
References: <5593648D.7020804@gmail.com> <559364E9.1070808@gmail.com> <20150701052007.GA17109@ZenIV.linux.org.uk>
In-Reply-To: <20150701052007.GA17109@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/1/2015 1:20 PM, Al Viro wrote:
> On Wed, Jul 01, 2015 at 11:56:25AM +0800, Kinglong Mee wrote:
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfs/client.c | 10 +++-------
>>  1 file changed, 3 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index a13fada..52488ec 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -1447,13 +1447,11 @@ int __init nfs_fs_proc_init(void)
>>  	/* a file of volumes that we have mounted */
>>  	p = proc_symlink("volumes", proc_fs_nfs, "../../net/nfsfs/volumes");
> 
> Why not make that
> 	if (!proc_symlink("fs/nfs/volumes", NULL, "../../net/nfsfs/volumes"))
> instead, and kill proc_fs_nfs completely?

That's great. Thank you!

thanks,
Kinglong Mee
 
