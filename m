Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:34671 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754277AbcCMXCO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Mar 2016 19:02:14 -0400
Received: by mail-vk0-f53.google.com with SMTP id e185so189500475vkb.1
        for <linux-nfs@vger.kernel.org>; Sun, 13 Mar 2016 16:02:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160311230254.GG2792@jra3>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
	<20160311140134.GA14808@infradead.org>
	<CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
	<CAH2r5mv3OTmPOQBV7xc-uZmB0gWxykXOCEVOcybx3tbHiViTZg@mail.gmail.com>
	<20160311230254.GG2792@jra3>
Date: Mon, 14 Mar 2016 00:02:13 +0100
Message-ID: <CAHc6FU5Bq9afVdNogc9DQYyyXwLfUopXW5ZnSuct3N+NvKW4Rg@mail.gmail.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Jeremy Allison <jra@samba.org>
Cc: Steve French <smfrench@gmail.com>, Christoph Hellwig <hch@infradead.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 12, 2016 at 12:02 AM, Jeremy Allison <jra@samba.org> wrote:
> On Fri, Mar 11, 2016 at 02:05:16PM -0600, Steve French wrote:
>> Sounds like I need to quickly rework the SMB3 ACL helper functions
>> for cifs.ko
>>
>> Also do you know where is the current version of the corresponding
>> vfs_richacl for
>> Samba which works with the current RichACL format?
>
> I have a patch for a new vfs_richacl somewhere. I remember
> sending it to Andreas for testing...

Ah, the patch was for testing, not resting ... how could I get that mixed up.

I've applied your patch to the latest master branch, made it compile
again, and fixed a few obvious problems. The results I get with
smbcacls look reasonable now.

The code is here:
  https://github.com/andreas-gruenbacher/samba richacl

I've used the following smb.conf:
  [richacl]
  comment = Richacl directory
  path = /mnt/ext4
  vfs objects = richacl
  writeable = yes
  browseable = yes

Is there a particular reason why you didn't make vfs_richacl a
dynamically loadable module?

Thanks,
Andreas
