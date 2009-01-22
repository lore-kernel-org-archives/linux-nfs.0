From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting a server.
Date: Thu, 22 Jan 2009 12:06:29 -0500
Message-ID: <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:61551 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbZAVRGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 12:06:45 -0500
In-Reply-To: <497805A7.4070205@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 22, 2009, at Jan 22, 2009, 12:35 AM, Ben Greear wrote:
> Chuck Lever wrote:
>> A handful of generic comments.
>>
>> 1.  This needs to be broken into smaller patches before submission;  
>> preferably before you submit another version for review.  Take a  
>> look at the linux-nfs@vger.kernel.org archives to see how we handle  
>> large changes like this.
>>
>> 2.  You should support local addresses only in the text-based path  
>> (utils/mount/stropts.c) and not in the legacy paths (utils/mount/ 
>> nfs[4]mount.c).  I don't think we're ever going to allow a version  
>> 7 of the mount data structure.
> I could remove the version 7 data field, but what about the other  
> code that creates
> sockets for 'pinging' nfs daemons and such?   Is that code  
> deprecated now?

It's still used for text-based NFSv2/v3 mounts, and unmounts.  The  
mount option rewriting code in stropts.c probably needs to be  
sensitive of the local address too.  That's the piece that uses all  
the getport functions.

> If nothing else, it looks like "probe_bothports" needs a client-addr  
> to pass on
> to methods it calls, and so forth.  That means that other code that  
> calls those
> methods needs to be updated, and thus my huge repetitive patch.

Expanding the synopses of all the getport calls in support/nfs/*.c is  
part of what can be split into separate patches.  I would start with  
support/nfs/rpc_socket.c (the lowest level) and move upwards.

Note that only some of these functions are actually used.  Some are  
included just to provide a complete getport API.

Just an idea: you might consider allowing the passed in local sockaddr  
to point to NULL.  In that case, just default to INADDR_ANY.  That  
might make the upper levels easier to code.

>> 3.  There are some umount-related changes coming up for IPv6 that  
>> will touch the umount paths here; that may require some changes in  
>> your modifications.
> That should be fine.   I tried to make my current patch friendly for  
> IPv6 and want to support local
> IPv6 binding as well.

The upcoming IPv6 support adds a new unmount function that replaces  
the functions that currently support only sockaddr_in.  That new  
function is probably what you would need to modify instead of updating  
the mnt_* functions, which will only be used by the legacy part of the  
mount.nfs command after my patches.

>> 4.  This needs to have support for a new mount option in the kernel  
>> (not a command-line option to the mount.nfs command, as you have  
>> implemented) to handle passing the address to the kernel.
> I think I already have this ready in the kernel, but I've been using  
> the version 7 field to pass
> in data using mount.nfs.

A new mount data version does not have anything to do with text-based  
mounts, which is how this should be supported.  You will have to add  
support for a new mount option in the text-based mount option parser  
in the kernel's fs/nfs/super.c.

>    Can you give an example of a user-space command that would use the
> new mount option as you suggest?  Do you do /etc/fstab any different  
> for instance?

Let's call it "localaddr=".  Something like:

   mount -o tcp,vers=3,localaddr=192.168.0.59 server:/export

I think this address would also need to be passed to the kernel's  
lockd at mount time by expanding the argument list to nlmclnt_init()  
and nlmclnt_lookup_host() in the kernel NFS client.  I think lockd  
already has some ability to support a local address, but that may be  
server-side only.

Still thinking about what needs to be done for NSM/statd.

You will also need to take some care with how NFSv4 generates the  
SETCLIENTID request, which sends the client's IP callback address and  
port to the server.  That will have to take the specified local  
address instead.  Take a look at the logic in stropts.c around the  
clientaddr= option.

If neither localaddr= or clientaddr= is specified, call  
nfs_callback_address().  If clientaddr= is specified, use the value of  
clientaddr=.  If localaddr= is specified, but clientaddr= is not, use  
the localaddr= value.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
