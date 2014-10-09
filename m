Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58068 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaJIQVa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Oct 2014 12:21:30 -0400
Date: Thu, 9 Oct 2014 09:21:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Steve French <smfrench@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Lukas Czerner <lczerner@redhat.com>
Subject: Re: xfstests and linux nfs testing
Message-ID: <20141009162127.GA12500@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54368292.8060209@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 09, 2014 at 08:41:54AM -0400, Anna Schumaker wrote:
> I think this is a bug in xfstests.  This fixes it for me, but I'm not sure what needs to be checked in the NFS case:

Lukas broke this with:
 common: Check fs consistency on TEST_DEV only when needed

as far as I can tell it blindly copied the _require_scratch code
to _require_test, which is bad for two reasons:

 a) due to lots of code duplication
 b) because it broke filesystems that don't support a scratch dev
    like nfs.

Anna fix should work, can you resend it to the fstests lists with a
proper signoff?  Even better would be some validation that the
passed in "device" is a valid format for a nfs export, but that's not
strictly required.
