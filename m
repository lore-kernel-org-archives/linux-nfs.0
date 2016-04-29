Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404AbcD2OMH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 10:12:07 -0400
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
To: andros@netapp.com, trond.myklebust@primarydata.com
References: <1461771407-16423-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <57236BB6.50103@RedHat.com>
Date: Fri, 29 Apr 2016 10:12:06 -0400
MIME-Version: 1.0
In-Reply-To: <1461771407-16423-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Andy,

On 04/27/2016 11:36 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> RFC patchset
> 
> Main question: Do we want to use multiple hostnames on the mount command to
>    communicate the NFSv4.1 session trunking addresses, or only use (yet
>    to be coded) fs_locations_info?
> 
> The multiple hostnames on the mount command are added to a new multiaddr
> option and passed to the kernel for consumption.
Should there be some type of man page update talking about his new option
and how to used it?

steved.

> 
> This code requires the kernel "Version 3 NFSV4.1,2 session trunking"
> patch set.
> 
> If we want to keep the multiple hostnames on the mount command method of
> expressing NFSv4.1 session trunking addresses, we should fix this:
> 
> - v3 mounts with multiple hostnames succeeds but adds an mtab dev entry that
> omits the ":/<exported dir> and so prints a warning at umount.
> - need to update the manpage
> 
> -->Andy
> 
> Andy Adamson (2):
>   NFS parse NFSv4 multiple hostnames
>   NFS add multiaddr mount option
> 
>  utils/mount/parse_dev.c | 30 +++++++++++++++--------
>  utils/mount/parse_dev.h |  2 +-
>  utils/mount/stropts.c   | 63 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  utils/mount/utils.c     |  2 +-
>  4 files changed, 84 insertions(+), 13 deletions(-)
> 
