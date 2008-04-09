From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] mount.nfs: fix retry option settings with binary
	mount options
Date: Wed, 9 Apr 2008 17:42:21 -0400
Message-ID: <20080409214221.GO32475@fieldses.org>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com> <1206822608-20154-2-git-send-email-jlayton@redhat.com> <47FD0447.9030704@RedHat.com> <20080409141323.0c594185@barsoom.rdu.redhat.com> <47FD15FB.6090208@RedHat.com> <20080409153021.3947925b@barsoom.rdu.redhat.com> <47FD22F1.4030704@RedHat.com> <47FD354B.9020103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbYDIVmX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 17:42:23 -0400
In-Reply-To: <47FD354B.9020103@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 09, 2008 at 05:29:47PM -0400, Peter Staubach wrote:
> Steve Dickson wrote:
>> Jeff Layton wrote:
>>   
>>> Yes. But like I mentioned in the description, there is a potential
>>> corner case here. If someone does a foreground mount and
>>> explicitly sets retry=10000 then it will be reset to 2. It's not very
>>> likely, but is simple enough to prevent...
>>>     
>> hmm.. I guess... but programing for every single brain dead
>> corner case can really make the code more complicated than
>> it need to be, which I think is the case here... I think I would
>> rather just added the three lines and live that corner case...
>
> Customers tend to be remarkably good at finding corner cases and
> then wondering why they don't work as advertised...

And 10000 is a nice round number.  Given more than a few users,
*somebody* is going to try it eventually, and get extremely confused.

--b.
