From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 11/12] svcrdma: Add a message log string to indicate if
	FastReg is being used
Date: Wed, 22 Oct 2008 16:23:45 -0400
Message-ID: <20081022202345.GC5572@fieldses.org>
References: <1223069629-5267-10-git-send-email-tom@opengridcomputing.com> <1223069629-5267-11-git-send-email-tom@opengridcomputing.com> <1223069629-5267-12-git-send-email-tom@opengridcomputing.com> <20081008224840.GF14527@fieldses.org> <48EDA691.9080108@opengridcomputing.com> <20081009162623.GD28785@fieldses.org> <48EE5193.2090702@opengridcomputing.com> <20081010210245.GF19415@fieldses.org> <48F2AFDA.8000704@opengridcomputing.com> <48F2B054.9040605@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36111 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639AbYJVUXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 16:23:48 -0400
In-Reply-To: <48F2B054.9040605@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 12, 2008 at 09:20:04PM -0500, Tom Tucker wrote:
> Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Thu, Oct 09, 2008 at 01:46:43PM -0500, Tom Tucker wrote:
>>>  
>>>> Coming up with a name for the command is probably
>>>> harder than writing it.
>>>>
>>>> Here it is...
>>>>     
>>>
>>> Neat-o, thanks.
>>>
>>> Just for fun, I installed libibverbs from Fedora 9, modprobe'd
>>> ib_uverbs, and tried running this, and got a "libibverbs: Warning:
>>> couldn't open config directory '/etc/libibverbs.d'."  Is there a HOWTO
>>> somewhere that I should know about?
>>>   
>> Hmm. Sounds like the Fedora RPM didn't do all the necessary bits. I  
>> have a Fedora 9 system,
>> I'll see what I get. I typically use the latest OFED distro.
>>
>
> I should qualify this. I use the OFED distro for the user-mode bits. For  
> kernel bits, I use top of
> tree.

I poked around the redhat bugzilla for any reports and didn't find
anything....  Is there a package from the OFED distro that I should look
at to get the idea?

--b.
