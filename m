Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm12-vm6.bullet.mail.ne1.yahoo.com ([98.138.91.105]:45983 "EHLO
        nm12-vm6.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752477AbdFNUxL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 16:53:11 -0400
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem
 context [ver #5]
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
References: <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com>
 <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
 <1402.1497472929@warthog.procyon.org.uk>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
Date: Wed, 14 Jun 2017 13:53:09 -0700
MIME-Version: 1.0
In-Reply-To: <1402.1497472929@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/14/2017 1:42 PM, David Howells wrote:
> Casey Schaufler <casey@schaufler-ca.com> wrote:
>
>> Could you namespace the fields of this structure?
>> e.g. fs_cred, fs_security
> Linus objects to that practice.

Sigh. Never mind. Thank you.

>
> David
>

