Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:62129 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751198AbeENLbx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 07:31:53 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <jlayton@kernel.org>
Subject: Re: [PATCH v2] nfsd: fix error handling in nfs4_set_delegation()
References: <20180509120249.62022-1-aweits@rit.edu>
        <20180511213005.GF3765@fieldses.org>
Date: Mon, 14 May 2018 07:31:53 -0400
In-Reply-To: <20180511213005.GF3765@fieldses.org> (J. Bruce Fields's message
        of "Fri, 11 May 2018 17:30:05 -0400")
Message-ID: <m21see79sm.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> +	/*
>> +	 * This delegation is doomed, tell the recall logic
>> +	 * that it's being destroyed here.
>> +	 */
>> +
>> +	if (status) {
>> +		dp->dl_time++;
>> +		list_del_init(&dp->dl_recall_lru);
>> +		dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
>> +	}
>
> I'm trying to figure out if this fixes an actual bug.  The code should
> be able to deal with a callback on an already unhashed delegation, so I
> think you're right it would at worst just be an unnecessary recall.

But an 'normal' unhashed delegation would have a persistent refcount,
this one would not. If the recall code gets a hold of it, it will
place it on nn->del_recall_lru, and then free it in nfsd4_cb_recall_release()?

> This won't catch every such case (could be that nfsd4_cb_recall_prepare
> already ran and we're too late), so I wonder if this is worth it.
>
> More interesting to me is what exactly it would take to hit this
> case....  Another thread would have to have succesfully hashed a
> delegation for this client and file to make our hash_delegation_locked
> fail.  So there would be two leases for the same file and client, but
> with different delegation pointers as the fl_owner.  I *think* we handle
> that OK.  But it was likely problematic previously when we were still
> using the file pointer as the fl_owner.

I'm thinking this is more easily hit via fp->fi_had_conflict, if a lease
break comes in at the right time?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
