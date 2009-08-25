From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 13:02:19 -0500
Message-ID: <4A94272B.2090004@sun.com>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
 <20090821200403.GA23529@fieldses.org>
 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
 <1250889345.5700.11.camel@heimdal.trondhjem.org>
 <20090821213016.GG23529@fieldses.org>
 <1250890836.5700.19.camel@heimdal.trondhjem.org>
 <20090821214720.GH23529@fieldses.org>
 <1250891463.5700.21.camel@heimdal.trondhjem.org>
 <20090824161004.GB4985@fieldses.org>
 <1251133618.6325.262.camel@heimdal.trondhjem.org>
 <20090824174129.GD4985@fieldses.org>
 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com>
 <95D9E216-A5E5-4B4F-AB50-2724AD5E8C96@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-1.Sun.COM ([192.18.98.31]:49952 "EHLO
	brmea-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512AbZHYSCy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 14:02:54 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7PI2uT0026005
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 18:02:56 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOY000001EWGT00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Tue,
 25 Aug 2009 12:02:56 -0600 (MDT)
In-reply-to: <95D9E216-A5E5-4B4F-AB50-2724AD5E8C96@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Aug 25, 2009, at 12:49 PM, Tom Haynes wrote:
>> Chuck Lever wrote:
>>>
>>> RFC 2623 suggests how the server should sort the returned flavor 
>>> list.  However I don't think there's a consistent algorithm the 
>>> client can use with that list to determine a good default for that 
>>> mount.  So, I would argue that any client that uses the "first" or 
>>> "last" entry in that list as the mount's auth flavor is probably 
>>> broken; it should pick a sec= default for all mounts, and if it's 
>>> not on the returned list, fail the mount.  That is, incidentally, 
>>> what the kernel MNT client does now.
>>>
>>
>>  The MOUNT Version 3 protocol, associated with NFS Version 3, solves
>>  the problem by having the response to the MNT procedure include a
>>  list of flavors in the MNT procedure. Note that because some NFS
>>  servers will export file systems to specific lists of clients, with
>>  different access (read-only versus read-write), and with different
>>  security flavors, it is possible a client might get back multiple
>>  security flavors in the list returned in the MNT response. The use of
>>  one flavor instead of another might imply read-only instead of read-
>>  write access, or perhaps some other degradation of access. For this
>>  reason, a NFS client SHOULD use the first flavor in the list that it
>>  supports, on the assumption that the best access is provided by the
>>  first flavor. NFS servers that support the ability to export file
>>  systems with multiple security flavors SHOULD either present the best
>>  accessing flavor first to the client, or leave the order under the
>>  control of the system administrator.
>>
>>
>>
>> It sounds pretty clear,
>
> Depends on how you define "best access."  Besides there's no 
> indication in the returned list of whether the access granted by the 
> server will be r/w, r/o, or what.
>

The quote addresses that - there is no way beforehand to determine 
whether the
client wants r/w access, etc. So the server defines the access ordering. 
I.e., if
the export is:

/foo  sec=krb5,rw,sec=sys,ro

The admin is stating I'll grant you r/w access only if you are secure.

But consider:

/bar sec=krb5,rw,sec=sys,rw=@10.10.20/24,ro

Which states that if you are on the management network, you can get r/w 
access
with AUTH_SYS.

In this case, the admin is also stating that they would prefer you use 
kerberos, even
if you are on the management network, But they won't penalize you.

And consider:

/open sec=sys:krb5,rw
/somewhat_secure sec=krb5:sys,rw

The second one is designed to have people use kerberos first and the 
first allows
people to use kerberos if they have it.

A client can force the issue with:

mount -o sec=krb5 server:/open /mnt

but in the absence of that information, they will most likely get the 
first flavor.


The way the spec handles this mess is simple, the server admin knows how 
they
want to restrict access to their export/share. So they configure the 
export and
the list of flavors goes out in the order they provided.

And the client should *trust* the server and use the first suported one. 
If the
user tries:

mount -o server:/foo /mnt

and realizes they do not have r/w permissions, they check the export 
access list
and do:

umount /mnt
mound -o sec=krb5 server:/foo /mnt



>> the server SHOULD order them in some fashion and the client SHOULD
>> pick the first one it supports in the list. It is not 'MUST', but if 
>> all servers and clients follow the same
>> algorithm, it becomes accepted practice.
>
> There was a reason for picking the last one on the list rather than 
> the first, but I don't remember what it was.  Clients ought to behave 
> consistently across implementations, but we unfortunately have some 
> behavioral precedents.
>
>> Having said that, our nfssec(5) states that a client can pick any of 
>> the modes in the list.
>>
>> But our server returns them in the order entered in the share by the 
>> admin.
>
> Which seems like it too ignores the 2623 prescription...?


Nope, read the last line I quoted.


>
>> The client either:
>>
>> 1) Uses the explicit flavor set in the mount command.
>> or
>> 2) Uses the first supported one in the list.
>> or
>> 3) Fails the mount.
>>
>> With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we 
>> support the autonegotiation
>> as defined in the protocol.
>>
>> We just went through a regression with this algorithm.
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>

