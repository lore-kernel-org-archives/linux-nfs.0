Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43110 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863Ab3AXNfe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 08:35:34 -0500
Message-ID: <5101388F.3070408@panasas.com>
Date: Thu, 24 Jan 2013 15:35:11 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steven Whitehouse <swhiteho@redhat.com>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
        Abhijith Das <adas@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Steve Dickson <steved@redhat.com>
Subject: [LSF/MM TOPIC] [ATTEND] New API's for better exporting of FSs from
 user-mode daemons, like readdirplus and more
References: <1358934230.2728.16.camel@menhir>
In-Reply-To: <1358934230.2728.16.camel@menhir>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is of high interest also for the NFS-Ganesha project, a
free software NFS user-mode daemon project. (CC: Ganesha ML)

I would (highly) second this topic, please, which is of cardinal
importance for any such sharing servers from user-mode.

Also in Ganesha we do not use (and cannot use) any form of
POSIX readdir, we must directly open the directory, and retrieve
the undocumented dirents structures. There are lots of reasons
why we do this, but mainly because of the directory-seek and
the readdir continuation "cookie". Which is impossible with
POSIX.

I can't, remember all the details right now, but Trond has showed
us how POSIX readdir is totally broken in regard to the continuation
"cookie", because POSIX assumes that the directory is a flat array.

So surly any implementation should also solve this issue.

Also in Ganesha we have portability layers for other OSs, and
we have been porting some Linux APIs to FreeBSD, A new proposal
should be well defined and have Portability and "generic-ness"
in mind. For example it should not only map readdirplus call
from an NFS daemon to a Local file system, it should also fit
well with an application API to an NFS client, with maximum
efficiency and minimum overhead.

Any implementation should also consider the in Kernel daemon.
Any generic VFS code that could be shared should be considered.
KNFSD should not be duplicating code already done by the above
IOCTL layer.

I would also like to propose that we might want to broaden this
topic to more API's that we might need from user-mode, like
delegation locks, and other. (We had a list of them I'll try
to collect and produce a list)

Thanks, and Steven, please forgive me if you feel I'm hijacking
your topic, if you feel our topics should be kept separate, please
tell me and I will send it as a separate topic.

Thanks
Boaz

On 01/23/2013 11:43 AM, Steven Whitehouse wrote:
> Hi,
> 
> As part of the work we've been doing in relation to integration between
> NFS/Samba and GFS2, Abhi has been working on a readdirplus system call
> in order to investigate the issues involved with creating such a call.
> It is still early days yet, but by April there should be some
> interesting results to present.
> 
> Please add Abhi to the attendee list as well as myself. 
> 
> Also, it has been some time since we had a NFS/Samba meeting to discuss
> the other issues which are pending, such as locking, ACLs, etc. So we
> could perhaps also allow some time to do that face to face rather than
> over the phone as we've been doing up til now,
> 
> Steve.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

