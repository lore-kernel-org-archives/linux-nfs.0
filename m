Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60030 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2MTE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:19:04 -0400
Date: Sun, 29 Sep 2013 05:19:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
Message-ID: <20130929121903.GF21083@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220968-14669-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:42:48PM -0400, Benny Halevy wrote:
> we don't want to hold the state_lock while the file system may block

Needs a much beter changelog:

 - why don't you want to hold it
 - why you think the new version is safe and performs fine.

