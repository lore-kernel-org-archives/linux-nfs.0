From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 001/100] nfsd4: probe callback channel only once
Date: Mon, 28 Jan 2008 13:48:07 -0500
Message-ID: <20080128184807.GE16785@fieldses.org>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <68314FDD-D9D1-4DAA-9BC1-423612F05907@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbYA1SsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 13:48:08 -0500
In-Reply-To: <68314FDD-D9D1-4DAA-9BC1-423612F05907@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 12:35:48PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>> Our callback code doesn't actually handle concurrent attempts to probe
>> the callback channel.  Some rethinking of the locking may be required.
>> However, we can also just move the callback probing to this case.   
>> Since
>> this is the only time a client is "confirmed" (and since that can only
>> happen once in the lifetime of a client), this ensures we only probe
>> once.
>
> Applying 001/100 without applying 002/100 will probably break  
> bisectability.

You lost me here.  Why?  I'm probably just missing something obvious.

--b.
