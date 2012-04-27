Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:43724 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759603Ab2D0DL2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 23:11:28 -0400
Subject: Re: [PATCH 1/6] xstat: Add a pair of system calls to make extended file stats available
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120427005121.GD9541@dastard>
Date: Thu, 26 Apr 2012 21:11:21 -0600
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Message-Id: <066E4E15-FE60-4D1C-9616-4679EE700CF6@dilger.ca>
References: <5D4BF4AB-47E9-4E25-B2A3-F895C98BDAA3@dilger.ca> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419140612.17272.57774.stgit@warthog.procyon.org.uk> <18195.1335447156@redhat.com> <20120427005121.GD9541@dastard>
To: Dave Chinner <david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-26, at 6:51 PM, Dave Chinner wrote:
> On Thu, Apr 26, 2012 at 02:32:36PM +0100, David Howells wrote:
>> I wonder if there's a way to make this explicit - or is it something that if the bit isn't set, you can't use the value in st_blksize.
>> I wonder if this value always has to be non-zero to make sure existing
>> stat() doesn't explode.
> 
> More likely it probably needs to be non-zero to prevent applications
> doing division by block size from exploding... ;)

Right, and any application which knows it needs the blocksize should
also be requesting it when using the statxat() (or whatever) syscall.

Cheers, Andreas





