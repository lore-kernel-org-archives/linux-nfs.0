Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:24734 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbaJIRg5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2014 13:36:57 -0400
Message-ID: <5436C7B5.7040700@Netapp.com>
Date: Thu, 9 Oct 2014 13:36:53 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Steve French <smfrench@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        <fstests@vger.kernel.org>, Lukas Czerner <lczerner@redhat.com>
Subject: Re: xfstests and linux nfs testing
References: <20141009162127.GA12500@infradead.org>
In-Reply-To: <20141009162127.GA12500@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/09/14 12:21, Christoph Hellwig wrote:
> On Thu, Oct 09, 2014 at 08:41:54AM -0400, Anna Schumaker wrote:
>> I think this is a bug in xfstests.  This fixes it for me, but I'm not sure what needs to be checked in the NFS case:
> 
> Lukas broke this with:
>  common: Check fs consistency on TEST_DEV only when needed
> 
> as far as I can tell it blindly copied the _require_scratch code
> to _require_test, which is bad for two reasons:
> 
>  a) due to lots of code duplication
>  b) because it broke filesystems that don't support a scratch dev
>     like nfs.
> 
> Anna fix should work, can you resend it to the fstests lists with a
> proper signoff?  Even better would be some validation that the
> passed in "device" is a valid format for a nfs export, but that's not
> strictly required.

Sure!  I'll fix up the patch so it doesn't have commented out lines while I'm at it :).  I'll take a stab at server format validation, and then send something out!

Anna
> 

