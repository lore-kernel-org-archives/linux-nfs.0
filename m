Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753580AbbD2PjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 11:39:23 -0400
Date: Wed, 29 Apr 2015 11:39:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: fix potential GSSX_ACCEPT_SEC_CONTEXT decoding
 failures
Message-ID: <20150429153922.GC18344@fieldses.org>
References: <1430252993-20091-1-git-send-email-smayhew@redhat.com>
 <1430255365.13607.165.camel@willson.usersys.redhat.com>
 <20150429153834.GB18344@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150429153834.GB18344@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:38:34AM -0400, J. Bruce Fields wrote:
> On Tue, Apr 28, 2015 at 05:09:25PM -0400, Simo Sorce wrote:
> > Thanks Scott,
> > I think this will help with older GSS-Proxy versions, in the newer
> > versions we are simply suppressing the exported composite name as the
> > kernel has no use for it.
> 
> Thanks.  (Also adding a Reviewed-by: Simo Sorce <simo@redhat.com>.)

(And a stable cc:.)

--b.
