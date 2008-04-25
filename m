From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 19:38:33 +0200
Message-ID: <20080425173833.GA7306@uio.no>
References: <20080425080535.GA4999@uio.no> <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com> <20080425163457.GA6952@uio.no> <F4C3F5C0-1D60-4285-9CB3-171C70C96B03@oracle.com> <20080425165921.GA7108@uio.no> <9CE7224B-002F-48B8-9DCB-8776A61167EF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:51723 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760447AbYDYRig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 13:38:36 -0400
In-Reply-To: <9CE7224B-002F-48B8-9DCB-8776A61167EF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 01:11:02PM -0400, Chuck Lever wrote:
> Just change "*timeout +=" to "*timeout =" in parse_retry_option().
>
> That was the bug I was trying to fix in the first place.  Sigh.

That fixes it -- thanks!

/* Steinar */
-- 
Homepage: http://www.sesse.net/
