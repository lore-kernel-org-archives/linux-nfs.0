Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60512 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751974AbdFNUmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 16:42:17 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com>
References: <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: dhowells@redhat.com, mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem context [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 14 Jun 2017 21:42:09 +0100
Message-ID: <1402.1497472929@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Casey Schaufler <casey@schaufler-ca.com> wrote:

> Could you namespace the fields of this structure?
> e.g. fs_cred, fs_security

Linus objects to that practice.

David
