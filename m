From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was fine
Date: Wed, 15 Apr 2009 13:35:09 -0400
Message-ID: <BCC012A8-842D-4699-917C-47ADF25446C7@oracle.com>
References: <200904151250.49372.hpj@urpla.net> <200904151548.12291.hpj@urpla.net> <0D024344-54E3-4A09-BE78-3E67667E05E7@oracle.com> <200904151923.58709.hpj@urpla.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:31617 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286AbZDORf2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 13:35:28 -0400
In-Reply-To: <200904151923.58709.hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 15, 2009, at 1:23 PM, Hans-Peter Jansen wrote:
> Am Mittwoch, 15. April 2009 schrieb Chuck Lever:
>>
>> When using rpcbind instead of portmapper, what does the output of
>> "rpcinfo" look like on the server?
>
> It's dumped in the mail starting this thread.

I don't see why the client's rpcbind attempt for the server's mountd  
service should have failed.

Would it be possible for you to capture a packet trace of the client's  
attempt to mount it's root file system?  (You will likely need to do  
this for a bugzilla report, anyway).

On the server you can use "tcpdump -s0 -w /tmp/raw host " followed by  
the hostname of your client.  It might be useful to capture both a  
failed session (with rpcbind) and a working session (with  
portmapper).  We want the raw (binary) trace dumps, not text output.

Also let us know what's running on your clients (distribution, kernel  
version, etc).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
