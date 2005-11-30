From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS cache consistancy appears to be broken...
Date: Wed, 30 Nov 2005 09:47:14 -0500
Message-ID: <1133362034.8625.12.camel@lade.trondhjem.org>
References: <200510281607.j9SG7Tll024133@hera.kernel.org>
	 <438D0E80.2020905@RedHat.com> <1133334608.8010.9.camel@lade.trondhjem.org>
	 <438DB65D.8010306@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751234AbVK3Ord@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <438DB65D.8010306@RedHat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2005-11-30 at 09:25 -0500, Steve Dickson wrote:

> It was the simple fact that nfsi->cache_change_attribute was not being 
> initialized to jiffies when the nfs inode was being allocated. This
> meant when nfs_revalidate_mapping() was called with the
> NFS_INO_INVALID_DATA bit was on, nfsi->cache_change_attribute
> was not being changed, it was actually being set!

That makes sense. Thanks!

Cheers,
  Trond
