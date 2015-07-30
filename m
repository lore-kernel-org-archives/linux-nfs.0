Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37631 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3XGm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 19:06:42 -0400
Received: by wibud3 with SMTP id ud3so10419289wib.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 16:06:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <73C1935C-77E2-41B4-A952-6F5C161A87E0@oracle.com>
References: <CA+X5Wn5OMj--ObKAMv0XVNj5wtQc_5hnhjc0Gb_v9=DFVANNuw@mail.gmail.com>
	<73C1935C-77E2-41B4-A952-6F5C161A87E0@oracle.com>
Date: Thu, 30 Jul 2015 23:06:41 +0000
Message-ID: <CABRuA+hMZJUojTMWAgz3ov5A=VkXhG87ym9v3ZUGmuOCs2AnVg@mail.gmail.com>
Subject: Re: NFS with RDMA mounts, but can't actually be used
From: Michael Darling <darlingm@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: james harvey <jamespharvey20@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 9:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Cc: nfs-rdma-devel removed. I think that's a dead list.

Looks like you're right.  My initial mail to it bounced back.

> Try specifying vers=4.0 explicitly.

This works!   Also, vers=4.1 fails with the same behavior in my original post.

Does this mean there's a bug in vers 4.1-4.2, or something else?
