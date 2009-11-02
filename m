From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6 support
Date: Mon, 2 Nov 2009 11:40:47 -0500
Message-ID: <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
References: <4AEE9645.6010503@suse.de>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27499 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782AbZKBQlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2009 11:41:39 -0500
In-Reply-To: <4AEE9645.6010503@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 2, 2009, at 3:20 AM, Suresh Jayaraman wrote:
> Hi Chuck et al,
>
> Thanks for all the excellent work on IPv6 support. There have been
> considerable amount of development that has been happening recently.
> However, it's not very clear what are the missing pieces or open
> problems (if any).

There's a working document on the linux-nfs.org wiki that has a full  
list, but I can't seem to get to linux-nfs.org right now.

> From what I understand, the current status is (CMIW):
>
> + kernel support
>  - client side and server (kernel pieces) are almost there and the
>    missing pieces are expected to get in by 2.6.32.

The client-side implementation of IPv6 in the kernel is usable.   
There's been a request for the proto= mount option to accept netids  
instead of protocol names, and that's still pending.  Otherwise, you  
can pass an IPv6 address to the kernel and it will do the right  
thing.  NFSv4 is pretty much working now, NFSv2/v3 still needs the  
IPv6-aware statd.  We've tested against NetApp and Solaris NFS servers.

Server side in the kernel is nearly done.  There are a handful of  
small patches outstanding.  Until I have mountd working, there's no  
way to test the server side pieces thoroughly.  So for now,  
"completion" of the server side is some time in the future.

> + userspace support
>  - nfsd support has already been added but disabled temporarily till
>    we get statd and mountd IPv6 aware.
>  - making statd IPv6 aware is currently under development/review.

Basic support is code complete and has seen some testing.  We're  
waiting for upstream NFS maintainers to review the latest patch series.

>  - mount.nfs changes - done?

The netid changes mentioned above will require some mount.nfs support,  
which is in the works.  2.6.33, maybe?

>  - rpc.mountd, exportfs changes - TBD.

These are the next step.  This is going to be a fairly heavy-weight  
change -- mountd and exportfs internals are unsuited for  
internationalized domain names, IPv6, and mixed IPv4/IPv6  
environments, and will need to be replaced.

There is also the gssd twins.  Jeff has fixed up at least one of  
them.  I think we've reviewed the kerberos libraries and determined  
that they are IPv6-aware, but that could be incorrect.  TCP wrappers  
are definitely not IPv6-aware.

rpcbind and libtirpc are also prerequisites, but there are few  
distributions I know of that have replaced portmapper with rpcbind.

> How far we are from getting full IPv6 support?

The short answer is mountd/exportfs will take about six months.  The  
client side is close enough that I think we can promise basic IPv6  
support for upcoming enterprise releases.  We're also thinking the  
kernel work on the server is close enough that few or no kABI changes  
will be needed once mountd is working, but that's just a guess.

The long answer depends on your definition of "full".  :-)

Does that include complete support for link-local IPv6 addresses?   
Does that include full support for netids in the kernel?  Does that  
include complete multi-homed host support in lockd and statd?  Does  
that include full support for internationalized domain names?  Does  
that include IPv6 netgroup support?  Does it include IPv6 support in  
TCP wrappers?  Does it include support for systems that have no IPv4  
addresses (not even loopback)?

There are a bunch of details that still need to be worked through.   
I've only been able to guess at what features are required, and which  
can be implemented at a later time.  What I would dearly love to have  
is a list of specific features that folks feel is a baseline (based on  
actual data, of course).  Unfortunately there are very few Linux  
customers who have deployed IPv6 and an IPv6-capable NFS  
implementation (like Solaris) and can tell us what they would need on  
Linux.

Plus, most distributions don't have fluent user space infrastructure  
for IPv6 yet.  NetworkManager is one area that may need work.  The  
Network Administration tool in Fedora is still IPv4-centric, iirc.  We  
don't have firewall admin tools that handle IPv6 rules.  Unlike IPv4,  
admins can (and often do) use IPv6-aware kernels without ipv6.ko, so  
all of our tools and support have to be careful about using IPv6 when  
the O/S may not support it.  This is different than IPv4, which is  
nearly always available.

In other words, system support for IPv6 outside of NFS is kind of like  
wireless was 5 years ago -- innumerable small admin tools that users  
had to integrate themselves, usually without much success.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



