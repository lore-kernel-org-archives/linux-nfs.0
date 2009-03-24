From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: Removed a number of warn_unused_result warnings
Date: Tue, 24 Mar 2009 13:08:03 -0400
Message-ID: <74BEB80C-976E-48D5-B356-16534F210209@oracle.com>
References: <49C797C6.8030102@RedHat.com> <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com> <49C910C3.2090700@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:33368 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760520AbZCXRIf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 13:08:35 -0400
In-Reply-To: <49C910C3.2090700-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 24, 2009, at 12:56 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> I've actually already addressed all the cases you found under
>> utils/statd/... my re-writes replace both nsm_log() and note() with
>> calls to xlog(), and add return code checking to the write(2) calls.
> Sorry about that... but I already did the commit... since I wanted to
> get some testing asap..  so go head and send me the parts I broke
> and I will do the forward port...

This is all only in my tree, and I haven't finished it yet, so I will  
have to do the fix-ups myself.

>> Also, note that you can use the "%m" format specifier to generate the
>> same string you get from strerror(errno).
> Yeah.. I knew that... but I thought there some memory corruption
> or service denial issue with using "%m" so I've always stuck
> with '%d (%s)'.

I use %m routinely.  What exactly are these issues?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
