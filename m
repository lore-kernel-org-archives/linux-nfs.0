Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbbGaJVK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2015 05:21:10 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4fd8dd8ed76901a89d6cd17e50ac585ea929f1fb.1438331416.git.viresh.kumar@linaro.org>
References: <4fd8dd8ed76901a89d6cd17e50ac585ea929f1fb.1438331416.git.viresh.kumar@linaro.org> <cover.1438331416.git.viresh.kumar@linaro.org> <cover.1438331416.git.viresh.kumar@linaro.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: dhowells@redhat.com, akpm@linux-foundation.org,
        linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Boaz Harrosh <ooo@electrozaur.com>, Christoph Hellwig <hch@lst.de>,
        ecryptfs@vger.kernel.org (open list:ECRYPT FILE SYSTEM),
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>, Joe Perches <joe@perches.com>,
        linux-cifs@vger.kernel.org (open list:COMMON INTERNET FILE SYSTEM
	(CIFS)),
        linux-ext4@vger.kernel.org (open list:EXT4 FILE SYSTEM),
        linux-fsdevel@vger.kernel.org (open list:FILESYSTEMS (VFS and
	infrastructure)),
        linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND LOCKD CLIENTS),
        Peng Tao <tao.peng@primarydata.com>,
        Petr Vandrovec <petr@vandrovec.name>,
        samba-technical@lists.samba.org (moderated list:COMMON INTERNET FILE
	SYSTEM (CIFS)),
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Tom Haynes <loghyr@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 12/15] fs: Drop unlikely before IS_ERR(_OR_NULL)
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 31 Jul 2015 10:20:56 +0100
Message-ID: <396.1438334456@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Viresh Kumar <viresh.kumar@linaro.org> wrote:

> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> is no need to do that again from its callers. Drop it.
> 
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>

Reviewed-by: David Howells <dhowells@redhat.com>
