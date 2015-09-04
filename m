Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:11408 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933735AbbIDVDH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 17:03:07 -0400
Subject: Re: [PATCH v1 3/8] btrfs: add .copy_file_range file operation
To: Anna Schumaker <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-api@vger.kernel.org>, <zab@zabbo.net>,
        <viro@zeniv.linux.org.uk>, <clm@fb.com>, <darrick.wong@oracle.com>,
        <mtk.manpages@gmail.com>, <andros@netapp.com>, <hch@infradead.org>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-4-git-send-email-Anna.Schumaker@Netapp.com>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <55EA06E7.9060306@fb.com>
Date: Fri, 4 Sep 2015 17:02:31 -0400
MIME-Version: 1.0
In-Reply-To: <1441397823-1203-4-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2015 04:16 PM, Anna Schumaker wrote:
> From: Zach Brown <zab@redhat.com>
>
> This rearranges the existing COPY_RANGE ioctl implementation so that the
> .copy_file_range file operation can call the core loop that copies file
> data extent items.
>
> The extent copying loop is lifted up into its own function.  It retains
> the core btrfs error checks that should be shared.
>
> Signed-off-by: Zach Brown <zab@redhat.com>
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

This bit looks fine to me,

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
