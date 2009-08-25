From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 13:40:44 -0400
Message-ID: <95D9E216-A5E5-4B4F-AB50-2724AD5E8C96@oracle.com>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com> <1250889345.5700.11.camel@heimdal.trondhjem.org> <20090821213016.GG23529@fieldses.org> <1250890836.5700.19.camel@heimdal.trondhjem.org> <20090821214720.GH23529@fieldses.org> <1250891463.5700.21.camel@heimdal.trondhjem.org> <20090824161004.GB4985@fieldses.org> <1251133618.6325.262.camel@heimdal.trondhjem.org> <20090824174129.GD4985@fieldses.org> <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:48349 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441AbZHYRlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 13:41:36 -0400
In-Reply-To: <4A94162C.20904-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 25, 2009, at 12:49 PM, Tom Haynes wrote:
> Chuck Lever wrote:
>>
>> RFC 2623 suggests how the server should sort the returned flavor  
>> list.  However I don't think there's a consistent algorithm the  
>> client can use with that list to determine a good default for that  
>> mount.  So, I would argue that any client that uses the "first" or  
>> "last" entry in that list as the mount's auth flavor is probably  
>> broken; it should pick a sec= default for all mounts, and if it's  
>> not on the returned list, fail the mount.  That is, incidentally,  
>> what the kernel MNT client does now.
>>
>
>  The MOUNT Version 3 protocol, associated with NFS Version 3, solves
>  the problem by having the response to the MNT procedure include a
>  list of flavors in the MNT procedure. Note that because some NFS
>  servers will export file systems to specific lists of clients, with
>  different access (read-only versus read-write), and with different
>  security flavors, it is possible a client might get back multiple
>  security flavors in the list returned in the MNT response. The use of
>  one flavor instead of another might imply read-only instead of read-
>  write access, or perhaps some other degradation of access. For this
>  reason, a NFS client SHOULD use the first flavor in the list that it
>  supports, on the assumption that the best access is provided by the
>  first flavor. NFS servers that support the ability to export file
>  systems with multiple security flavors SHOULD either present the best
>  accessing flavor first to the client, or leave the order under the
>  control of the system administrator.
>
>
>
> It sounds pretty clear,

Depends on how you define "best access."  Besides there's no  
indication in the returned list of whether the access granted by the  
server will be r/w, r/o, or what.

> the server SHOULD order them in some fashion and the client SHOULD
> pick the first one it supports in the list. It is not 'MUST', but if  
> all servers and clients follow the same
> algorithm, it becomes accepted practice.

There was a reason for picking the last one on the list rather than  
the first, but I don't remember what it was.  Clients ought to behave  
consistently across implementations, but we unfortunately have some  
behavioral precedents.

> Having said that, our nfssec(5) states that a client can pick any of  
> the modes in the list.
>
> But our server returns them in the order entered in the share by the  
> admin.

Which seems like it too ignores the 2623 prescription...?

> The client either:
>
> 1) Uses the explicit flavor set in the mount command.
> or
> 2) Uses the first supported one in the list.
> or
> 3) Fails the mount.
>
> With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we  
> support the autonegotiation
> as defined in the protocol.
>
> We just went through a regression with this algorithm.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



