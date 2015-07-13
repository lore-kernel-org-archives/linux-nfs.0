Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:58100 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbGMJBn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:01:43 -0400
Date: Mon, 13 Jul 2015 02:01:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] blkmapd: Skip the SCSI ID if data length is zero
Message-ID: <20150713090142.GA28557@infradead.org>
References: <55A2FEE4.6030201@gmail.com>
 <20150713064216.GA31842@infradead.org>
 <55A375A1.4000800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A375A1.4000800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kinglong,

I meant to describe the rational as a comment in the code, not as
a more verbose commit log.
