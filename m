From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Fri, 25 Apr 2008 10:19:54 -0400
Message-ID: <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23591 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbYDYOUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 10:20:21 -0400
In-Reply-To: <20080425080128.GA4848-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 4:01 AM, Steinar H. Gunderson wrote:
> On Thu, Apr 24, 2008 at 10:12:58AM -0400, Chuck Lever wrote:
>> Start with "mount.nfs -v" to see if the mount command tells you  
>> anything
>> interesting.  Then do a raw network trace to see what's failing  
>> during
>> the mount version/protocol negotiation.
>
> There's nothing in -v except that it adds an addr= field. As for the
> packet dump, that's the most interesting part -- for my part, the  
> server
> doesn't have iptables, so I'm blocking on the client. In that case,  
> exactly zero packets enter the write before mount gives up...

The kernel may be returning an incorrect return code to the mount  
command.

Set the NFSDBG_MOUNT flag before you try your mount, then look in /var/ 
log/messages.  That will show you the kernel part of the mount  
process.  And/or use strace with the mount command.

> The other submitters have iptables blocking on the server, though,  
> and it
> doesn't work for them either (one is using NFSv3, the other NFSv4).  
> Is this really working for you?

I can't say until you post a complete description of a specific test  
case.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
