Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35930 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754171Ab0HRUqS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:46:18 -0400
Message-ID: <4C6C4697.3060309@panasas.com>
Date: Wed, 18 Aug 2010 23:46:15 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@infradead.org>
CC: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/50] pnfs_submit: set and unset pnfs layoutdriver modules
References: <1281735122-1496-3-git-send-email-andros@netapp.com> <1281735122-1496-4-git-send-email-andros@netapp.com> <1281735122-1496-5-git-send-email-andros@netapp.com> <1281735122-1496-6-git-send-email-andros@netapp.com> <1281735122-1496-7-git-send-email-andros@netapp.com> <1281735122-1496-8-git-send-email-andros@netapp.com> <1281735122-1496-9-git-send-email-andros@netapp.com> <1281735122-1496-10-git-send-email-andros@netapp.com> <1281735122-1496-11-git-send-email-andros@netapp.com> <1281735122-1496-12-git-send-email-andros@netapp.com> <20100818203126.GE16851@infradead.org>
In-Reply-To: <20100818203126.GE16851@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 18, 2010, 23:31 +0300, Christoph Hellwig <hch@infradead.org> wrote:
> I don't think such a fine-grained splitup is reviewable at all.
> Anything more than a couple of patches for core nfs client changes, 
> one patch for core pnfs support and one for the file layout driver
> is simply too much.
> 

The whole enchilada is about 8500 lines of diff.
Don't you think that splitting it up to self contained bite-sized patches
is better for reviewing it?

Benny
