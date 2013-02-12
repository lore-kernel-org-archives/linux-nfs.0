Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipo2-out.fzu.cz ([147.231.27.21]:35927 "EHLO ipo2-out.fzu.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932953Ab3BLODu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 09:03:50 -0500
Message-ID: <511A4B90.9010007@gmail.com>
Date: Tue, 12 Feb 2013 15:02:56 +0100
From: Jiri Horky <jiri.horky@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 server ignores local filesystem's POSIX ACL
References: <51190E62.5090304@gmail.com> <20130211182212.GB30117@fieldses.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3C2047@sacexcmbx05-prd.hq.netapp.com> <20130211184936.GC30117@fieldses.org> <5119572C.3080000@gmail.com> <20130211210133.GF30117@fieldses.org> <20130211214144.GA32745@fieldses.org>
In-Reply-To: <20130211214144.GA32745@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
On 02/11/2013 10:41 PM, J. Bruce Fields wrote:
> On Mon, Feb 11, 2013 at 04:01:33PM -0500, J. Bruce Fields wrote:
>> That shouldn't matter (assuming it's not actually owned by "nobody" on
>> the server.)
> Beats me.  The network trace does indeed seem to show a succesful create
> (and a preceding access op that allows access that I would have expected
> to fail).
>
> I don't see how that could have happened--the server doesn't actually
> enforce the ACL itself, it depends on common vfs code for that, so
> there's probably something obvious we're overlooking.  You're positive
> the file's being created in the same directory that you set that acl on?
>
> --b.
we tracked the cause down to the "enhanced xfs" module from SGI 
(sgi-enhancedxfs-kmp-default-2.5_2.6.32.12_0.7-sgi250rp13.sles11). With 
a standard xfs module 
(sgi-xfs-kmp-default-6.5.0.14_2.6.32.12_0.7-sgi12111921) or on a ext3 
file systems, the server respects ACL correctly. Seems like the 
enhancement went into wrong direction :) Lets file a bug against the vendor.

Cheers
Jiri Horky

