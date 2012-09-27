Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64700 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303Ab2I0Mfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 08:35:45 -0400
Message-ID: <5064481D.8080006@netapp.com>
Date: Thu, 27 Sep 2012 08:35:41 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: William Dauchy <wdauchy@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFS: Remove bad delegations during open recovery
References: <1348687553-8461-1-git-send-email-bjschuma@netapp.com> <CAJ75kXZHD9nkL_bEzqd-L=5OVmxQjEwgPT_2Oj2pfCjfMdK_5w@mail.gmail.com>
In-Reply-To: <CAJ75kXZHD9nkL_bEzqd-L=5OVmxQjEwgPT_2Oj2pfCjfMdK_5w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/2012 06:19 PM, William Dauchy wrote:
> On Wed, Sep 26, 2012 at 9:25 PM,  <bjschuma@netapp.com> wrote:
>> This causes a loop because the client never updates the nfs4_state after
>> discovering that the delegation is invalid.  This means it will keep
>> trying to read using the bad delegation rather than attempting to re-open
>> the file.
> 
> Oh, I already encountered this bug but never found the time to debug
> it / report it.
> 
> Thanks a lot! I'll try to test it soon.
> 

Awesome!  Let me know how your tests go, thanks.

- Bryan
