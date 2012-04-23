Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56370 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913Ab2DWWat convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 18:30:49 -0400
Received: by obbta14 with SMTP id ta14so76162obb.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 15:30:48 -0700 (PDT)
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage type
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <4F95D65A.8070608@redhat.com>
Date: Mon, 23 Apr 2012 17:42:02 -0500
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com
Message-Id: <A754D23B-B946-4E80-ACEA-0E2C2E6FAA2E@whamcloud.com>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <4F91C15B.6070200@redhat.com> <4F93FED6.6090505@itwm.fraunhofer.de> <4F95BD72.6090200@redhat.com> <4F95C109.1030401@itwm.fraunhofer.de> <4F95D65A.8070608@redhat.com>
To: Eric Sandeen <sandeen@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-23, at 5:23 PM, Eric Sandeen wrote:
> I'm curious about the above as well as:
> 
>        case SEEK_END:
>                if (unlikely(offset > 0))
>                        goto out_err; /* not supported for directories */
> 
> The previous .llseek handler, and the generic handler for other filesystems, allow seeking past the end of the dir AFAICT.  (not sure why you'd want to, but I don't see that you'd get an error back).
> 
> Is there a reason to uniquely exclude it in ext4?  Does that line up with POSIX?

I don't know what the origin of this was...  I don't think there is a real reason for it except that it doesn't make any sense to do so.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/




