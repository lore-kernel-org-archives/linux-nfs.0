Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:35298 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121Ab3J2PMa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 11:12:30 -0400
Date: Tue, 29 Oct 2013 08:12:29 -0700
From: Greg KH <gregkh@linuxfoundation.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0 message
 or a v1 message
Message-ID: <20131029151229.GA31890@kroah.com>
References: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9534E866F@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9534E866F@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 10:59:45PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: Myklebust, Trond
> > Sent: Monday, October 28, 2013 6:57 PM
> > To: linux-nfs@vger.kernel.org; Bruce Fields
> > Cc: stable@vger.kernel.org
> > Subject: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0 message
> > or a v1 message
> > 
> > Add the missing 'break' to ensure that we don't corrupt a legacy 'v0' type
> > message by appending the 'v1'.
> > 
> > Cc: Bruce Fields <bfields@fieldses.org>
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> 
> I did not intend to send this to stable@vger.kernel .org before it has hit upstream...

Don't worry, as you were just cc: stable@ with your normal patch
submission process, I can tell that this isn't to be applied now, it's
part of the development process.  So don't feel bad at all, lots of
other subsystems do it, and it doesn't bother me at all, no need to
filter it away.

greg k-h
