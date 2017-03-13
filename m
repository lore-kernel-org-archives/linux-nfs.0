Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36848 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750740AbdCMECX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Mar 2017 00:02:23 -0400
Received: by mail-it0-f68.google.com with SMTP id w185so4925561ita.3
        for <linux-nfs@vger.kernel.org>; Sun, 12 Mar 2017 21:02:23 -0700 (PDT)
Subject: Re: some problems about nfs mount
To: houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <4898582f.561c.15ac5c271ea.Coremail.hou.linfei@h3c.com>
Cc: bfields@fieldses.org, neilb@suse.com, SteveD@redhat.com,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <0c613918-4e92-fee8-2c39-35280578ece3@gmail.com>
Date: Mon, 13 Mar 2017 12:02:10 +0800
MIME-Version: 1.0
In-Reply-To: <4898582f.561c.15ac5c271ea.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/13/2017 11:42, houlinfei wrote:
> hi Kinglong:
> 
> At server,
> #cat /etc/exports
> /root/hh *(rw,sync,insecure,subtree_check,no_root_squash)
> #cat /proc/fs/nfsd/versions
> -2 +3 +4 +4.1 +4.2
> 
> At client,
> #mount -t nfs 193.168.70.26:/root/hh /mnt/uu
> mount.nfs: access denied by server while mounting 192.168.70.26:/root/hh

Everything is okay on my test machine.
Is it failed every client? or only one client?
What't the state of filewalld ? Can you try again with filewalld turndown?

thanks,
Kinglong Mee
