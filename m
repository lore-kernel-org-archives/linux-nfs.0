Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47420 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaCGPgk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 10:36:40 -0500
Received: by mail-pa0-f49.google.com with SMTP id lj1so4281737pab.22
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2014 07:36:40 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] Stop Background mounts hang from hanging
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394204563-1166-1-git-send-email-steved@redhat.com>
Date: Fri, 7 Mar 2014 10:36:37 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <D803A861-E660-4D20-BDE1-00D8C45A1228@primarydata.com>
References: <1394204563-1166-1-git-send-email-steved@redhat.com>
To: Dickson Steve <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2014, at 10:02, Steve Dickson <steved@redhat.com> wrote:

> Background mounts hang forever due to the kernel not returning 
> the time out error. The proposed fix is twofold, one in the kernel 
> and one in the mounting code.
> 
> The kernel patch stop the server trunking code from endlessly 
> looping in the kernel on -ETIMEDOUT errors. Instead, the code 
> will now return the error, allowing the mount to go into 
> the background.
> 
> Unfortunately, it takes over 5 mins for this timeout to 
> happen, due the default retry strategy, which is unacceptable 
> for background mounts. 
> 
> So the patch I will be proposing for the mount code will be 
> to append the "retrans=1,timeo=100" mount options to the parent
> mount of the background mount (when they don't exist). This
> causes the parent mount to timeout in ~25sec. 

We already have a ‘retry=‘ option for mount.nfs. According to the manpage, that should be used to specify the timeout value. Why not reuse that?

Also, it really would be better if that timeout were under control of the mount utility itself. How about if we allow the use of alarm() to interrupt that particular RPC call?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

