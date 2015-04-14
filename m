Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:5828 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932067AbbDNRMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 13:12:07 -0400
Message-ID: <552D4972.9010509@fb.com>
Date: Tue, 14 Apr 2015 13:08:02 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
To: Zach Brown <zab@redhat.com>, <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-scsi@vger.kernel.org>
Subject: Re: [PATCH RFC 3/3] btrfs: add .copy_file_range file operation
References: <1428703236-24735-1-git-send-email-zab@redhat.com> <1428703236-24735-4-git-send-email-zab@redhat.com>
In-Reply-To: <1428703236-24735-4-git-send-email-zab@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/10/2015 06:00 PM, Zach Brown wrote:
> This rearranges the existing COPY_RANGE ioctl implementation so that the
> .copy_file_range file operation can call the core loop that copies file
> data extent items.
> 
> The extent copying loop is lifted up into its own function.  It retains
> the core btrfs error checks that should be shared.
> 

Thanks Zach, the btrfs bits look reasonable

Signed-off-by: Chris Mason <clm@fb.com>

-chris

