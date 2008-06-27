From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Fri, 27 Jun 2008 10:06:44 -0400
Message-ID: <76bd70e30806270706x7cbfd291l6cb6d0cc5e81771@mail.gmail.com>
References: <62137472-FF31-40A2-904D-A9CC2C76B032@oracle.com>
	 <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Benny Halevy" <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	"Peter Staubach" <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Krishna Kumar2" <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:64231 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423AbYF0OGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jun 2008 10:06:46 -0400
Received: by an-out-0708.google.com with SMTP id d40so108648and.103
        for <linux-nfs@vger.kernel.org>; Fri, 27 Jun 2008 07:06:45 -0700 (PDT)
In-Reply-To: <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 27, 2008 at 5:04 AM, Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
> Chuck Lever <chuck.lever@oracle.com> wrote on 06/26/2008 11:12:58 PM:
>> > Local:
>> >      Read:  69.5 MB/s
>> >      Write: 70.0 MB/s
>> > NFS of same FS mounted loopback on same system:
>> >      Read:  29.5 MB/s  (57% drop)
>> >      Write: 27.5 MB/s  (60% drop)
>>
>> You can look at client-side NFS and RPC performance metrics using some
>> prototype Python tools that were just added to nfs-utils.  The scripts
>> themselves can be downloaded from:
>>     http://oss.oracle.com/~cel/Linux-2.6/2.6.25
>> but unfortunately they are not fully documented yet so you will have
>> to approach them with an open mind and a sense of experimentation.
>>
>> You can also capture network traces on your loopback interface to see
>> if there is, for example, unexpected congestion or latency, or if
>> there are other problems.
>>
>> But for loopback, the problem is often that the client and server are
>> sharing the same physical memory for caching data.  Analyzing your
>> test system's physical memory utilization might be revealing.
>
> But loopback is better than actual network traffic.

What precisely do you mean by that?

You are testing with the client and server on the same machine.  Is
the loopback mount over the lo interface, but you mount the machine's
actual IP address for the "network" test?

I would expect that in that case, loopback would perform better
because a memory copy is always faster than going through the network
stack and the NIC.

It would be interesting to compare a network-only performance test
(like iPerf) for loopback and for going through the NIC.

> If my file size is
> less than half the available physical memory, then this should not be
> a problem, right?

It is likely not a problem in that case, but you never know until you
have analyzed the network traffic carefully to see what's going on.

>> Otherwise, you should always expect some performance degradation when
>> comparing NFS and local disk.  50% is not completely unheard of.  It's
>> the price paid for being able to share your file data concurrently
>> among multiple clients.
>
> But if the file is being shared only with one client (and that too
> locally), isn't 25% too high?

NFS always allows the possibility of sharing, so it doesn't matter how
many clients have mounted the server.

The distinction I'm drawing here is between something like iSCSI,
where only a single client ever mounts a LUN, and thus can cache
aggressively, versus NFS in the same environment, where the client has
to assume that any other client can access a file at any time, and
therefore must cache more conservatively.

You are doing cold cache tests, so this may not be at issue here either.

A 25% performance drop between a 'dd' directly on the server, and one
from an NFS client, is probably typical.

> Will I get better results on NFSv4, and should I try delegation (that
> sounds automatic and not something that the user has to start)?

It's hard to predict if NFSv4 will help because we don't understand
what is causing your performance drop yet.

Delegation is usually automatic if the client's mount command has
generated a plausible callback IP address, and the server is
successfully able to connect to it.  However, I didn't think the
server hands out a delegation until the second OPEN... with a single
dd, the client opens the file only once.

--
Chuck Lever
