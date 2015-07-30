Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39646 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbbG3XXq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 19:23:46 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFS with RDMA mounts, but can't actually be used
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CABRuA+hMZJUojTMWAgz3ov5A=VkXhG87ym9v3ZUGmuOCs2AnVg@mail.gmail.com>
Date: Thu, 30 Jul 2015 19:23:05 -0400
Cc: james harvey <jamespharvey20@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F5B6C7C3-F308-4390-975A-43C1439448BD@oracle.com>
References: <CA+X5Wn5OMj--ObKAMv0XVNj5wtQc_5hnhjc0Gb_v9=DFVANNuw@mail.gmail.com> <73C1935C-77E2-41B4-A952-6F5C161A87E0@oracle.com> <CABRuA+hMZJUojTMWAgz3ov5A=VkXhG87ym9v3ZUGmuOCs2AnVg@mail.gmail.com>
To: Michael Darling <darlingm@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 30, 2015, at 7:06 PM, Michael Darling <darlingm@gmail.com> wrote:

> On Thu, Jul 30, 2015 at 9:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Cc: nfs-rdma-devel removed. I think that's a dead list.
> 
> Looks like you're right.  My initial mail to it bounced back.
> 
>> Try specifying vers=4.0 explicitly.
> 
> This works!   Also, vers=4.1 fails with the same behavior in my original post.
> 
> Does this mean there's a bug in vers 4.1-4.2, or something else?

NFS/RDMA is not yet working with NFSv4.1 and NFSv4.2. It's a
known issue.

If no "vers=" mount option is specified, mount.nfs will start
negotiating now at 4.2. It used to start at 4.0.

--
Chuck Lever



