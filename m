Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34205 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdBYLBY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Feb 2017 06:01:24 -0500
Received: by mail-io0-f169.google.com with SMTP id 90so4922437ios.1
        for <linux-nfs@vger.kernel.org>; Sat, 25 Feb 2017 03:01:23 -0800 (PST)
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>
References: <18321972.53bcc4.15a74a7da99.Coremail.hou.linfei@h3c.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        bfields@fieldses.org, neilb@suse.com, SteveD@redhat.com,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <75ee7024-41c6-be43-5d98-dd6ab383cab0@gmail.com>
Date: Sat, 25 Feb 2017 18:51:25 +0800
MIME-Version: 1.0
In-Reply-To: <18321972.53bcc4.15a74a7da99.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/25/2017 17:44, houlinfei wrote:
> hi Kinglong,
>  I download nfs-utils-1.3.4, but it isn't has debian directory. So i can't build deb package on ubuntu system. Now, if nfs-utils-1.3.4 support ubuntu system?

I'm not familiar with ubuntu/debian,
but I think nfs-utils is supported on them.
Without debain directory, you can use the make/Makefile to install it
following the README.

# sh autogen.sh
# ./confiugre
# make
# make install 

thanks,
Kinglong Mee
