Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38330 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750866AbdFPPyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 11:54:33 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170616154959.GA27209@infradead.org>
References: <20170616154959.GA27209@infradead.org> <20170616090621.GA13775@infradead.org> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745338248.10897.17175227466711674034.stgit@warthog.procyon.org.uk> <20170615093927.GG31671@ZenIV.linux.org.uk> <9141.1497624810@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, Al Viro <viro@ZenIV.linux.org.uk>,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 07/27] VFS: Differentiate mount flags (MS_*) from internal superblock flags [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 16 Jun 2017 16:54:30 +0100
Message-ID: <654.1497628470@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> (1) Add a new SB field that is like s_flags but for the new flags,

Do we really need to do that?  The SB_* flags are conumeric with the MS_*
flags they replace.

David
