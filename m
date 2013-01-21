Return-Path: linux-nfs-owner@vger.kernel.org
Received: from s22.webhostingserver.nl ([195.211.72.238]:53080 "EHLO
	s22.webhostingserver.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167Ab3AUTiZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 14:38:25 -0500
Message-ID: <c7d3923f1438a9217cfbb53744b5be21.squirrel@vdtoorn.nl>
In-Reply-To: <20130121161123.GB16357@fieldses.org>
References: <26b3643c253ee306d593bb4b20ff095b.squirrel@vdtoorn.nl>
    <20130121161123.GB16357@fieldses.org>
Date: Mon, 21 Jan 2013 20:38:16 +0100
Subject: Re: Hanging nfs4+krb5 mounts with negative uids?
From: richard@vdtoorn.nl
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: richard@vdtoorn.nl, linux-nfs@vger.kernel.org
Reply-To: richard@vdtoorn.nl
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Well done! Your answer to upgrade to a later version of the kernel fixed
the problem. I tested this on kernel 3.7.3 and it works beautifully.

Thanks very much!

Richard

>> This code gets hit, e.g. with the new debian stable release where
>> nfs-kernel-server/nfs-common is upgraded to 1.2.6-3 (or upgrade
>> nfs-kernel-server from debian stable to debian unstable). On my
>> nfsv4+krb5
>> system, this seems to do exactly the opposite of the patch: not fixing,
>> but in fact introducing a hanging mount.
>>
>> When I change the code back from unsigned uid's to signed uid's the
>> mount
>> works again.
>
> Assuming you're running kernel 3.7--this shoulds like the problem fixed
> by kernel commit 621eb19ce1ec.. "svcrpc: Revert "sunrpc/cache.h: replace
> simple_strtoul"", which has also been backported to 3.7.3.  Could you
> let us know whether applying that patch, or upgrading to 3.7.3, fixes
> the problem?
>
> --b.




