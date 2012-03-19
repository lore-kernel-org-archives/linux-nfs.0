Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:36506 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756370Ab2CSSnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:43:50 -0400
Message-ID: <4F677E63.90300@rath.org>
Date: Mon, 19 Mar 2012 14:43:47 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
References: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca> <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca> <20120319173656.GA23670@fieldses.org> <126867CF-7CAA-4E3D-A9D6-2A5FE30A7DB4@oracle.com> <20120319182712.GB23670@fieldses.org> <A39DDC79-274A-427F-9887-28DD74BA56ED@oracle.com> <20120319183955.GC23670@fieldses.org>
In-Reply-To: <20120319183955.GC23670@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/19/2012 02:39 PM, J. Bruce Fields wrote:
> On Mon, Mar 19, 2012 at 02:29:46PM -0400, Chuck Lever wrote:
>>
>> On Mar 19, 2012, at 2:27 PM, J. Bruce Fields wrote:
>>
>>> On Mon, Mar 19, 2012 at 01:47:14PM -0400, Chuck Lever wrote:
>>>>
>>>> On Mar 19, 2012, at 1:36 PM, J. Bruce Fields wrote:
>>>>> Well, sure, but all I'm proposing here is returning NFS4ERR_INUSE in the
>>>>> case where we get setclientid's with the same client-provided id.
>>>>> There'd be no change of behavior in the case of multiple clients sharing
>>>>> an IP (which is fine, of course).
>>>>
>>>> The migration draft proposes that clients use the same nfs_client_id4 string for all of a server's IP addresses.  Would a server then be obliged to return NFS4ERR_CLID_IN_USE if a client attempts a SETCLIENTID with the same boot verifier and nfs_client_id4 on more than one IP address for the same server?
>>>
>>> That's also not this case, sorry, this time with all the conditions:
>>>
>>> 	- if the nfs_client_id4 is the same, and
>>> 	- if the flavor is auth_sys, and
>>> 	- if the client IP address is different,
>>> 	- then return NFS4ERR_INUSE.
>>
>> This still breaks for multi-homed servers and UCS clients.  The client IP address can be different depending on what server IP address the client is accessing, but all the other parameters are the same.
> 
> OK.  So probably there's nothing we can do to help here.
> 
> As a bandaid maybe a rate-limited log message ("clientid X now in use
> from IP Y") might help debug these things....

Since you guys keep Cc'ing me, I'll chime in with a rather naive
suggestion: if all that's required is a unique id for every client, why
not use the MAC of the first network interface, independent of it being
used for communication with the server?


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
