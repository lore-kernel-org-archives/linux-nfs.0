From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 5 May 2008 10:13:23 -0400
Message-ID: <B7077A85-1BDD-4E65-9F97-0AF1AF98A958@oracle.com>
References: <20080504223934.GA11746@vinvin.dyndns.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
To: vinvin-CCKDRK/Hd0cdbCeoMzGj59i2O/JbrIOy@public.gmane.org (vincent)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:27194 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350AbYEEONq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 10:13:46 -0400
In-Reply-To: <20080504223934.GA11746-CCKDRK/Hd0cdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 4, 2008, at 6:39 PM, vincent wrote:
>> Chuck Lever wrote:
>> Thanks for the offer.  I tested against a server configuration that
>> dropped UDP packets, but I never tested through an ssh tunnel.
>
> In the ssh tunnel case, what can be seen in network captures for
> localhost on the client is that mounting requests are sent over UDP,  
> and
> since the ports are those specified for the ssh tunnel, they lead to
> nothing on localhost UDP, and an ICMP dest unreach (port) is sent  
> back.
> This is made twice before mount.nfs exits with an internal error, 2
> packets each time.
>
> I have the same problem than Frank, using NFS through a ssh tunnel. It
> was working with 2.6.20 and I've just upgraded to 2.6.25 and it does  
> not
> works anymore.

After 2.6.23, mount options are passed to the kernel as a C string  
instead of binary data structure.  The mount command formerly  
contacted the server via the mountd protocol, and passed mount  
information to the kernel.  Now the kernel has its own mountd client  
and it uses that instead.

The new kernel mount option parser behaves a little differently than  
the user-space mount command with regard to the "proto=" option.  If  
you specify "proto=tcp" the legacy mount command contacts the server's  
mountd via TCP.  However, the kernel continues to use the default  
setting (UDP) for the mount client's transport protocol.

This is a bug, and I have a kernel patch that makes the kernel mount  
option parser behave like the legacy mount command.

Until this bug is addressed, you can use "mountproto=" to specify the  
transport protocol explicitly for the kernel's mount client.  See  
nfs(5) for details.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
