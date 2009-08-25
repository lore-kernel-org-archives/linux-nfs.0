From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 14:10:25 -0400
Message-ID: <20090825181025.GA29051@fieldses.org>
References: <20090821213016.GG23529@fieldses.org> <1250890836.5700.19.camel@heimdal.trondhjem.org> <20090821214720.GH23529@fieldses.org> <1250891463.5700.21.camel@heimdal.trondhjem.org> <20090824161004.GB4985@fieldses.org> <1251133618.6325.262.camel@heimdal.trondhjem.org> <20090824174129.GD4985@fieldses.org> <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com> <95D9E216-A5E5-4B4F-AB50-2724AD5E8C96@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36357 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755577AbZHYSK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 14:10:28 -0400
In-Reply-To: <95D9E216-A5E5-4B4F-AB50-2724AD5E8C96@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2009 at 01:40:44PM -0400, Chuck Lever wrote:
> On Aug 25, 2009, at 12:49 PM, Tom Haynes wrote:
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
> Depends on how you define "best access."  Besides there's no indication 
> in the returned list of whether the access granted by the server will be 
> r/w, r/o, or what.

For that reason, all servers I know of have decided to leave the "best
access" decision to the server administrator.

>> the server SHOULD order them in some fashion and the client SHOULD
>> pick the first one it supports in the list. It is not 'MUST', but if  
>> all servers and clients follow the same
>> algorithm, it becomes accepted practice.
>
> There was a reason for picking the last one on the list rather than the 
> first, but I don't remember what it was.  Clients ought to behave  
> consistently across implementations, but we unfortunately have some  
> behavioral precedents.

Yes, and we need some workarounds for those, as previously discussed,
but the above-quoted SHOULD can still be mostly honored.

>> Having said that, our nfssec(5) states that a client can pick any of  
>> the modes in the list.
>>
>> But our server returns them in the order entered in the share by the  
>> admin.
>
> Which seems like it too ignores the 2623 prescription...?

We declare the ordering a policy issue and leave it to the server
administrator.  The linux server does this as well, and the behavior is
documented in the exports(5) man page.

--b.
