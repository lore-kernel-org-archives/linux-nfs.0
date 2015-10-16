Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:10779 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbJPVmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 17:42:44 -0400
Subject: Re: [PATCH v6 5/4] copy_file_range.2: New page documenting
 copy_file_range()
To: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
References: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <56216F50.7030705@draigBrady.com>
Date: Fri, 16 Oct 2015 22:42:40 +0100
MIME-Version: 1.0
In-Reply-To: <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's probably worth mentioning the sparse expansion caveat
in the docs, as it's important and not obvious.

I.E. copy_file_range() could be called from, but would
still benefit from a user space app using a SEEK_{HOLE,DATA} loop.

thanks,
Pádraig.
