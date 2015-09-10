Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392AbbIJPnj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2015 11:43:39 -0400
Date: Thu, 10 Sep 2015 17:42:51 +0200
From: David Sterba <dsterba@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v1 9/8] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20150910154251.GM8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20150904213856.GC10391@birch.djwong.org>
 <55EEF8E3.8030501@Netapp.com>
 <20150908203918.GB30681@birch.djwong.org>
 <55F01A26.7070706@gmail.com>
 <20150909171757.GE10391@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150909171757.GE10391@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2015 at 10:17:57AM -0700, Darrick J. Wong wrote:
> I noticed that btrfs won't dedupe more than 16M per call.  Any thoughts?

btrfs_ioctl_file_extent_same:

3138         /*
3139          * Limit the total length we will dedupe for each operation.
3140          * This is intended to bound the total time spent in this
3141          * ioctl to something sane.
3142          */
3143         if (len > BTRFS_MAX_DEDUPE_LEN)
3144                 len = BTRFS_MAX_DEDUPE_LEN;

The deduplication compares the source and destination blocks and does
not use the checksum based approach (btrfs_cmp_data()). The 16M limit is
artifical, I don't have an estimate whether the value is ok or not. The
longer dedupe chunk the lower the chance to find more matching extents,
so the practially used chunk sizes are in range of hundreds of
kilobytes. But this obviously depends on data and many-megabyte-sized
chunks could fit some usecases easily.
