Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756612AbdEKTYk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 15:24:40 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <68231d1a-9902-ce3d-73e3-6e74754832e4@Netapp.com>
References: <68231d1a-9902-ce3d-73e3-6e74754832e4@Netapp.com> <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: dhowells@redhat.com, mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        jlayton@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 00/14] VFS: Introduce superblock configuration context [ver #2]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 11 May 2017 20:24:32 +0100
Message-ID: <9616.1494530672@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:

> Is there any way to split the NFS patch into multiple pieces?

Are you okay with a patch or two that add code that is unconnected in that
patch, but connected in a later one?

David
