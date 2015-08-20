Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33400 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbbHTQOV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 12:14:21 -0400
Received: by padfo6 with SMTP id fo6so25521807pad.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 09:14:20 -0700 (PDT)
Date: Thu, 20 Aug 2015 21:44:16 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
To: Steve French <smfrench@gmail.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, Boaz Harrosh <ooo@electrozaur.com>,
        "open list:NFS, Peng Tao <tao.peng@primarydata.com>, Petr Vandrovec
	<petr@vandrovec.name>, samba-technical@lists.samba.org moderated
	list:COMMON INTERNET FILE SYSTEM CIFS, Steve French <sfrench@samba.org>,
	Theodore Ts'o <tytso@mit.edu>, Tom Haynes <loghyr@primarydata.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>, Tyler Hicks
	<tyhicks@canonical.com>, Weston Andros Adamson <dros@primarydata.com>",
        <linux-nfs@vger.kernel.org>, linaro-kernel@lists.linaro.org,
        Jiri Kosina <trivial@kernel.org>,
        "open list:COMMON INTERNET FILE SYSTEM CIFS"
	<linux-cifs@vger.kernel.org>,
        "open list:ECRYPT FILE SYSTEM" <ecryptfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        David Howells <dhowells@redhat.com>,
        "open list:FILESYSTEMS VFS and infrastructure"
	<linux-fsdevel@vger.kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Fabian Frederick <fabf@skynet.be>,
        Andrew Morton <akpm@linux-foundation.org>,
        "open list:EXT4 FILE SYSTEM" <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH V1 Resend 07/10] fs: Drop unlikely before IS_ERR(_OR_NULL)
Message-ID: <20150820161416.GC4159@linux>
References: <cover.1439375087.git.viresh.kumar@linaro.org>
 <2efb962cb72884f625116cba24fc4fb203c6621f.1439375087.git.viresh.kumar@linaro.org>
 <20150812142815.27968b32@tlielax.poochiereds.net>
 <CAH2r5mvUC2WO6sVqhe_QCgiCJbRbahDsSj=-Uzk7LB_peTqjLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5mvUC2WO6sVqhe_QCgiCJbRbahDsSj=-Uzk7LB_peTqjLQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20-08-15, 11:08, Steve French wrote:
> Reviewed-by: Steve French <smfrench@gmail.com>
> 
> Do you want me to merge the fs/cifs part of this independently (into
> cifs-2.6.git staging tree) or are you going to merge all of this
> (which changes multiple fs) at one time through someone else's tree?

The plan is to merge via Trivial tree, but the Maintainer isn't
responding yet :)

-- 
viresh
