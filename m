Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932193AbdJJPYi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Oct 2017 11:24:38 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <27530b6a-7290-2171-899e-6c16c14f402e@infradead.org>
References: <27530b6a-7290-2171-899e-6c16c14f402e@infradead.org> <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk> <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock creation/configuration context [ver #6]
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Tue, 10 Oct 2017 16:24:36 +0100
Message-ID: <13483.1507649076@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Randy Dunlap <rdunlap@infradead.org> wrote:

> > + * generic_parse_monolithic - Parse key[=val][,key[=val]]* mount data
> > + * @mc: The superblock configuration to fill in.
> 
> function argument is &struct fs_context *ctx, not @mc

Yeah, Miklós and Al kept changing their minds about what I was allowed to call
this struct.

David
