Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:22219 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S932395AbeEWMbH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 08:31:07 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <jlayton@kernel.org>
Subject: Re: [PATCH v2] nfsd: fix error handling in nfs4_set_delegation()
References: <20180509120249.62022-1-aweits@rit.edu>
        <20180511213005.GF3765@fieldses.org>
        <m21see79sm.fsf@discipline.rit.edu>
        <20180514154550.GD7160@fieldses.org>
Date: Wed, 23 May 2018 08:31:05 -0400
In-Reply-To: <20180514154550.GD7160@fieldses.org> (J. Bruce Fields's message
        of "Mon, 14 May 2018 11:45:50 -0400")
Message-ID: <m2zi0qh7ue.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> But an 'normal' unhashed delegation would have a persistent refcount,
>> this one would not. If the recall code gets a hold of it, it will
>> place it on nn->del_recall_lru, and then free it in nfsd4_cb_recall_release()?
>
> Sounds right.  Do you see any bug there?

I'd expect it to crash in the laundromat. Unfortunately the larger test rig
that I'd normally use to try to hit this is occupied doing other things
- I may have to come back to this later.

Thanks,

Andy
