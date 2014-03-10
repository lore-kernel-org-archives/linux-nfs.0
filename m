Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53352 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaCJXkO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 19:40:14 -0400
Date: Mon, 10 Mar 2014 16:40:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
        Matthew Rahtz <mrahtz@rapitasystems.com>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: warning in ext4_journal_start_sb on filesystem freeze
Message-ID: <20140310234010.GA10938@infradead.org>
References: <1697998867.143517.1385454051031.JavaMail.zimbra@rapitasystems.com>
 <20131126125826.GA4503@quack.suse.cz>
 <622177618.727.1393062606061.JavaMail.zimbra@rapitasystems.com>
 <20140224095525.GA20532@quack.suse.cz>
 <20140224154532.GB11992@fieldses.org>
 <20140225102126.GB1669@quack.suse.cz>
 <20140304164306.GC12805@fieldses.org>
 <20140304190442.GE12805@fieldses.org>
 <20140310133451.GA17807@infradead.org>
 <20140310195709.GH28006@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310195709.GH28006@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 03:57:09PM -0400, J. Bruce Fields wrote:
> (Size is irrelevant, though, right?  Won't any setattr need an elevated
> write count?)

Indeed.  Not sure why I was thinking of truncate as a special case here.

