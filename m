From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] statd: not unlinking host files
Date: Mon, 08 Dec 2008 19:40:29 -0500
Message-ID: <493DBE7D.3010101@RedHat.com>
References: <493A8D71.20603@RedHat.com> <20081208233355.GB24083@fieldses.org> <E1EBCB84-864D-4463-811F-4B2610BCABFA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45303 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754528AbYLIAmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 19:42:54 -0500
In-Reply-To: <E1EBCB84-864D-4463-811F-4B2610BCABFA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Dec 8, 2008, at Dec 8, 2008, 6:33 PM, J. Bruce Fields wrote:
>> On Sat, Dec 06, 2008 at 09:34:25AM -0500, Steve Dickson wrote:
>>> Again working with the state file code, I notice that statd was
>>> not unlinking hosts files when the kernel sent up the
>>> sm_unmon messages. This following patch address the reason why...
>>>
>>> Comments?
>>
>> Bizarre--thanks for catching that.
>>
>> But it looks like these are actually the only two callers to xunlink?
>> In which case, we should just ditch the "check" parameter entirely and
>> avoid some confusion....
> 
> It looks like xunlink() doesn't check error returns properly either. 
> alloca() is a convenience, but the price is a SIGSEGV if the stack frame
> can't be extended.
> 
> For a system-level daemon like rpc.statd, I would rather see a proper
> implementation of this using malloc(3) or automatic storage, and
> ensuring that sprintf doesn't overrun its buffer.  This also makes it
> possible to track the buffer allocation here using valgrind.  alloca()
> is a completely inline implementation, according to its man page.
> 
> I'm not sure why statd has it's own implementation of xstrdup and
> xmalloc here as well; support/nfs/* already has both of these.  It would
> be worth getting rid of these too.
Added to the TODO list... 

steved.
