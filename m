Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4-phx2.redhat.com ([209.132.183.25]:36410 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab2EaMPs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 08:15:48 -0400
Date: Thu, 31 May 2012 08:14:46 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jan Kara <jack@suse.cz>, Steven Whitehouse <swhiteho@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 1/6] gfs2: Get rid of I_MUTEX_QUOTA usage
Message-ID: <f75ea307-1c26-4220-be4e-8944688ca271@zmail12.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1338429016-20119-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
| From: Jan Kara <jack@suse.cz>
| 
| GFS2 uses i_mutex on its system quota inode to synchronize writes to
| quota file. Since this is an internal inode to GFS2 (not part of
| directory
| hiearchy or visible by user) we are safe to define locking rules for
| it. So
| let's just get it its own locking class to make it clear.

Hi,

Acked-by: Bob Peterson <rpeterso@redhat.com>

Regards,

Bob Peterson
Red Hat File Systems
