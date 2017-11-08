Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:23223 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1752490AbdKHVmP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 16:42:15 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: fix locking validator warning on nfs4_ol_stateid->st_mutex class
References: <20171108005726.35092-1-aweits@rit.edu>
        <20171108205812.GP24262@fieldses.org>
Date: Wed, 08 Nov 2017 16:42:14 -0500
In-Reply-To: <20171108205812.GP24262@fieldses.org> (J. Bruce Fields's message
        of "Wed, 8 Nov 2017 15:58:12 -0500")
Message-ID: <m21sl8o3bd.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Tue, Nov 07, 2017 at 07:57:26PM -0500, Andrew Elble wrote:
>> The use of the st_mutex has been confusing the validator. Use the
>> proper nested notation so as to not produce warnings.
>
> Looking around, the usual pattern for simple nesting seems to be to use
> just mutex_lock() for the outer lock (equivalent to
> mutex_lock_nested(0)), and mutex_lock_nested(., SINGLE_DEPTH_NESTING)
> for the inner lock.
>
> Or we could define a new LOCK_STATEID_MUTEX, assuming the rule here is
> "lock stateid's are locked after open stateid's".  Just a question of
> might be simpler to understand.

I'm okay with whatever you think is best here - my thought was that the
mutex_lock_nested(0) called more attention to how it was working given
that acquiring that lock class the second time is now a little bit more
hidden in nfsd4_lock_ol_stateid().

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
