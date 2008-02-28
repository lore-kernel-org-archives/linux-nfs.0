From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: kernel 2.6 and simulated flock() with posix locks
Date: Thu, 28 Feb 2008 17:32:49 -0500
Message-ID: <20080228223249.GD30782@fieldses.org>
References: <47C2C09D.2010203@arx.net> <20080225163802.GB10402@fieldses.org> <47C2EFFB.40807@arx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbYB1Wcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2008 17:32:50 -0500
In-Reply-To: <47C2EFFB.40807-nz9JlX+3IF8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 25, 2008 at 06:42:35PM +0200, Thanos Chatziathanassiou wrote:
> J. Bruce Fields wrote:
>> On Mon, Feb 25, 2008 at 03:20:29PM +0200, Thanos Chatziathanassiou wrote:
>>   
>>> Hi,
>>>
>>> I've been trying to replace kernel 2.4 in a web server mounting its Document Root via NFS with kernel 2.6 and faced a rather disturbing problem.
>>> About 1/2 hour after starting, the server would stop serving requests though it seemed fine.
>>> Earlier 2.6 kernels exhibited the ``do_vfs_lock: VFS is out of sync with lock manager!'' symptom, later (when this was changed to a dprintk()) just sat there.
>>> No apparent error apart from apache compaining ``[error] server reached MaxClients setting, consider raising the MaxClients setting'', unable to serve any requests.
>>>
>>> This issue does not surface under 2.4, where everything works as expected.
>>> I came across this  
>>> (http://blog.notreally.org/articles/2007/12/19/modifying-a-live-linux-kernel/) 
>>> where apparently they faced the same problem, but their solution 
>>> (which seemed a little crude) resulted in apache spitting ``There are 
>>> no available locks'' messages (or roughly this, translated from my 
>>> regional settings).
>>>
>>> Is there any solution to this or a way to get 2.4 behavior under 2.6 ?
>>>     
>>
>> I'm a little confused--how do you know that the problem you face is the
>> same as the one described on the blog above?  Are you re-exporting NFS
>> via Samba?
>>
>> --b.
>>   
> Indeed I am. But I am willing to convince you ;) What kind of debug info  
> would I need to collect to find out what really the problem is ?

Can you give a more detailed explanation of the symptoms?  For example,
when you say "the server would stop serving requests", are you referring
to the web server or the nfs server?  If you think the problem is that
Apache is hanging on a lock, you should be able to verify that with
strace or /proc/locks or a sysrq-T trace.

--b.
