Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:49358 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754132Ab2EQV3U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 17:29:20 -0400
Message-ID: <4FB5698E.3000401@cora.nwra.com>
Date: Thu, 17 May 2012 15:11:42 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: Karel Zak <kzak@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Cannot unmount nfs4 sec=krb5 mount if network is down
References: <loom.20120510T222025-23@post.gmane.org> <loom.20120516T233017-710@post.gmane.org> <20120517102958.GA9844@x2.net.home>
In-Reply-To: <20120517102958.GA9844@x2.net.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2012 04:29 AM, Karel Zak wrote:
> On Wed, May 16, 2012 at 09:34:27PM +0000, Orion Poplawski wrote:
>> Orion Poplawski<orion@...>  writes:
>>>
>>> See https://bugzilla.redhat.com/show_bug.cgi?id=820707
>>>
>>> If the network is disconnected it is impossible to unmount, even if no
>>> processes are accessing the mount.  umount -f and umount -l both hang on
>>> readlink("/home/orion").
>>
>> umount needs to canonicalize the path so it does a readlink on the path given to
>> it.
>
> It seems that the canonicalization is unnecessary (already fixed in libmount
> upstream code). https://bugzilla.redhat.com/show_bug.cgi?id=820707
>

That appears to fix the issue for me.  Thanks!

>> This appears to wait forever.  This pretty much makes it impossible to use krb5
>> nfs4 with laptops where the network can disappear.
>
> Is it possible to interrupt this "wait" by signal? ... then we can add alarm()
> to critical sections in programs like umount or lsof.
>
> Now for example lsof resolves this problem by fork() and timeout in
> parent.. that's pretty nasty solution :-(
>
>      Karel
>

Seems unnecessary with the above fix.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
