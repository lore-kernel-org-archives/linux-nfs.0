From: Peter Staubach <staubach@redhat.com>
Subject: Re: about NLM/NSM
Date: Mon, 27 Oct 2008 15:22:57 -0400
Message-ID: <49061511.4050304@redhat.com>
References: <55BA1E9645B3441FA782D9032BDC9288@nrchpcvx1f5w93> <20081027185515.GB23767@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: hexf <hexiaofeng-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33353 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbYJ0TXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2008 15:23:07 -0400
In-Reply-To: <20081027185515.GB23767@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Oct 27, 2008 at 02:49:27PM +0800, hexf wrote:
>   
>> We are using nfsv3. Now we meet a demand. If a client which hold a
>> lock crash, after it reboot, its statd daemon can notify the nfs
>> server to release the lock.  But if this client will not reboot for
>> some reason(or will reboot after a long time), then the lock it
>> holding will not be released.In nfsv3 and nlmv4,it seems there is no
>> time-out mechnism for this situation. How would we solve this
>> question? My colleague advise me to modify the code of NLM/NSM to meet
>> this demand,but is seems quite a complicated work.Can you give me some
>> advice?
>>     
>
> It might be possible to modify the server so that it dropped all locks
> from a client it hadn't heard from in a while.  However, nfsv2/v3
> clients are not required to contact the server regularly while they hold
> locks.  So you may end up revoking locks held by perfectly good
> functioning clients.
>
> As an ugly workaround, rebooting the server will clear the problem, as
> it will notify clients to recover their locks on restart, and any dead
> clients will fail to recover their locks.
>
>   

Didn't Wendy Cheng submit some patches to implement a
"clearlocks" sort of functionality?  What happened with
them?

       ps

>> And if there are some schemes in nfsv4?
>>     
>
> NFSv4 requires clients to contact the server regularly as long as they
> hold any locks.  So NFSv4 does not have this particular problem.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

