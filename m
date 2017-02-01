Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34089 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdBANiK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 08:38:10 -0500
Received: by mail-io0-f176.google.com with SMTP id l66so156476122ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 01 Feb 2017 05:38:09 -0800 (PST)
Date: Wed, 1 Feb 2017 07:38:07 -0600
From: Seth Forshee <seth.forshee@canonical.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        Steve French <sfrench@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [REVIEW][PATCH] fs: Better permission checking for submounts
Message-ID: <20170201133807.GA136075@ubuntu-hedt>
References: <87efzsdq5b.fsf@xmission.com>
 <87inp4rqaj.fsf@xmission.com>
 <1485301593.36478.2.camel@primarydata.com>
 <87y3y0ko5s.fsf@xmission.com>
 <1485303265.36478.7.camel@primarydata.com>
 <20170125145251.GB51023@ubuntu-hedt>
 <1485359474.113155.1.camel@primarydata.com>
 <20170125162811.GC51023@ubuntu-hedt>
 <87mve6pgci.fsf@xmission.com>
 <87h94epg9y.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87h94epg9y.fsf_-_@xmission.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 01, 2017 at 07:38:17PM +1300, Eric W. Biederman wrote:
> 
> To support unprivileged users mounting filesystems two permission
> checks have to be performed: a test to see if the user allowed to
> create a mount in the mount namespace, and a test to see if
> the user is allowed to access the specified filesystem.
> 
> The automount case is special in that mounting the original filesystem
> grants permission to mount the sub-filesystems, to any user who
> happens to stumble across the their mountpoint and satisfies the
> ordinary filesystem permission checks.
> 
> Attempting to handle the automount case by using override_creds
> almost works.  It preserves the idea that permission to mount
> the original filesystem is permission to mount the sub-filesystem.
> Unfortunately using override_creds messes up the filesystems
> ordinary permission checks.
> 
> Solve this by being explicit that a mount is a submount by introducing
> vfs_submount, and using it where appropriate.
> 
> vfs_submount uses a new mount internal mount flags MS_SUBMOUNT, to let
> sget and friends know that a mount is a submount so they can take appropriate
> action.
> 
> sget and sget_userns are modified to not perform any permission checks
> on submounts.
> 
> follow_automount is modified to stop using override_creds as that
> has proven problemantic.
> 
> do_mount is modified to always remove the new MS_SUBMOUNT flag so
> that we know userspace will never by able to specify it.
> 
> autofs4 is modified to stop using current_real_cred that was put in
> there to handle the previous version of submount permission checking.
> 
> cifs is modified to pass the mountpoint all of the way down to vfs_submount.
> 
> debugfs is modified to pass the mountpoint all of the way down to
> trace_automount by adding a new parameter.  To make this change easier
> a new typedef debugfs_automount_t is introduced to capture the type of
> the debugfs automount function.
> 
> Cc: stable@vger.kernel.org
> Fixes: 069d5ac9ae0d ("autofs:  Fix automounts by using current_real_cred()->uid")
> Fixes: aeaa4a79ff6a ("fs: Call d_automount with the filesystems creds")
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks good to me. I also got testing from the user who reported the bug
to us, and it does fix his nfs submount problem.

Reviewed-by: Seth Forshee <seth.forshee@canonical.com>
