From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 14:45:54 -0400
Message-ID: <20080926184554.GA1492@fieldses.org>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net> <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42343 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762AbYIZSp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 14:45:57 -0400
In-Reply-To: <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 01:53:58PM -0400, Chuck Lever wrote:
> On Sep 25, 2008, at Sep 25, 2008, 5:38 PM, J. Bruce Fields wrote:
>> On Wed, Sep 24, 2008 at 02:50:36PM -0400, Chuck Lever wrote:
>>> statd and some servers always need lockd to listen on UDP, so always
>>> start both lockd listener sockets.
>>>
>>> This probably leaks an svc_serv if the TCP listener can't be created,
>>> but it will do for now.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> I currently have this workaround lurking in my git repo.  Is there  
>>> some kind
>>> of fix for this issue planned for 2.6.28?
>>
>> Not that I know of.
>>
>>> This is only a reminder, not a suggested patch.
>>
>> Any chance you could generate a patch?
>
> I can, but no guarantee it will be in time for the 2.6.28 merge window.
>
> Would we consider this a regression fix?

I suppose so.  (Are there any bug reports?  If so, could we get URL's
for them into the commit message?)

> If so, we could post it after 
> the merge window closes.  It would give a little more time to do some 
> testing.

That sound suspiciously like "since this is a high priority, it will be
accepted later, so we can make it a lower priority."  Help!

But anyway, yes, we might have more time.

--b.
