From: Matt Bernstein <+systems.extlists.nfsv4-9gaWkGYbp/DQzY9nttDBhA@public.gmane.org>
Subject: Re: Turning off delegations in NFSv4 server?
Date: Fri, 5 Mar 2010 15:12:46 +0000 (GMT)
Message-ID: <alpine.LRH.2.00.1003051239050.23376@frank.dcs.qmul.ac.uk>
References: <4786788D.6040707@garzik.org> <20080110200034.GI2132@fieldses.org> <alpine.LRH.2.00.1003040915110.23376@frank.dcs.qmul.ac.uk> <20100304143317.GA17191@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Matt Bernstein <mb/nfs4-/t1RSEU/v7tOXXNyRuEUqw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flan.dcs.qmul.ac.uk ([138.37.95.138]:36690 "EHLO
	mail.dcs.qmul.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138Ab0CEPMs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Mar 2010 10:12:48 -0500
In-Reply-To: <20100304143317.GA17191@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 4 J. Bruce Fields wrote:
> On Thu, Mar 04, 2010 at 09:23:26AM +0000, Matt Bernstein wrote:
>> On Jan 10 2008 J. Bruce Fields wrote:
>>> The easiest thing is probably just to turn off leases:
>>> 	echo 0 >/proc/sys/fs/leases-enable
>>
>> I found this from two years ago, and am wondering
>> - is this still the easiest thing to do?
>> - is this on server, client or both?
>> - will it break anything else?
>>
>> We have a CentOS 5.4 NFS3/NFS4/samba server with about 300 clients on its
>> subnet, and another 100-200 on another subnet, which under high load has
>> started kernel-panicking (sometimes in nfsd4_cb_recall).
>
> Have you filed a bug with the backtraces?

Duly nudged. I've posted the most recent one to 
<http://bugs.centos.org/view.php?id=4229>.

>> I want to disable delegations to see if that cures our symptoms--but I
>> worry that turning leases off might cause other problems.
>
> No, it shouldn't cause problems, at least for NFSv4 clients.  (Samba may
> be more reliant on leases, especially if Samba and NFSv4 clients are
> acting on the same files at the same time--but I don't know.)

Thanks; no-one's grumbled just yet.

Matt
