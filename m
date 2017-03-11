Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37935 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755129AbdCKAMh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Mar 2017 19:12:37 -0500
Received: by mail-it0-f46.google.com with SMTP id m27so5831211iti.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Mar 2017 16:12:36 -0800 (PST)
Subject: Re: some problems about nfs mount
To: houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <4cd2efd6.e025.15ab908d6d0.Coremail.hou.linfei@h3c.com>
 <6122045b-2c2a-cb0a-1f1c-3a0c21b72c5d@gmail.com>
Cc: bfields@fieldses.org, neilb@suse.com, SteveD@redhat.com,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <4b3515b7-81db-4305-4acd-fa53ad99a0af@gmail.com>
Date: Sat, 11 Mar 2017 08:12:30 +0800
MIME-Version: 1.0
In-Reply-To: <6122045b-2c2a-cb0a-1f1c-3a0c21b72c5d@gmail.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/11/2017 08:10, Kinglong Mee wrote:
> On 3/11/2017 00:24, houlinfei wrote:
>> hi Kinglong:
>> There has another problem about client mount using nfs4.My server system is ubuntu 14.04. nfs-kernel-server version is 1.3.4.My client system is ubuntu12.04.nfs-common version is 1.2.5.Then i mount the directory using nfs4.But it return "mount.nfs: access denied by server while mounting бн".When i mount using nfs3,it's ok.Do you know why?
> 
> Can you show me more information about the exports and your mount command line?

At server, 

# cat /etc/exports
# cat /proc/fs/nfsd/versions

At client,
# mount .....

thanks,
Kinglong Mee
