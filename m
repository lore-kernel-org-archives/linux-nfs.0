Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:54106 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965013Ab2B2XVh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Feb 2012 18:21:37 -0500
Message-ID: <4F4EB2FE.9040108@cora.nwra.com>
Date: Wed, 29 Feb 2012 16:21:34 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs4 mount hanging suddenly
References: <4F4EA6D0.30606@cora.nwra.com> <20120229231732.GD6506@fieldses.org>
In-Reply-To: <20120229231732.GD6506@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/29/2012 04:17 PM, J. Bruce Fields wrote:
> On Wed, Feb 29, 2012 at 03:29:36PM -0700, Orion Poplawski wrote:
>> Just starting today, one of our user's nfs mounted home directory
>> has started locking up.  Client is Fedora 16 32-bit, server is
>> CentOS 5.7 32-bit.  Have not seen this particular problem elsewhere
>> (yet).
>>
>> I captured this trace on the server after the hang:
>>
>> http://sw.cora.nwra.com/tmp/marie-nfs-home-lwang-hang.pcap
>>
>>    1   0.000000  10.10.20.15 ->  10.10.10.1   NFS V4 COMP Call<EMPTY>
>> PUTFH;GETATTR GETATTR
>>    2   0.000133   10.10.10.1 ->  10.10.20.15  NFS V4 COMP Reply (Call
>> In 1)<EMPTY>  PUTFH;GETATTR GETATTR
>>    3   0.000421  10.10.20.15 ->  10.10.10.1   TCP 879>  nfs [ACK]
>> Seq=137 Ack=225 Win=17738 Len=0 TSV=3584653 TSER=2438333196
>>    4   0.000519  10.10.20.15 ->  10.10.10.1   NFS V4 COMP Call<EMPTY>
>> PUTFH;ACCESS ACCESS;GETATTR GETATTR
>>    5   0.000587   10.10.10.1 ->  10.10.20.15  NFS V4 COMP Reply (Call
>> In 4)<EMPTY>  PUTFH;ACCESS ACCESS;GETATTR GETATTR[Unreassembled
>> Packet [incorrect TCP checksum]]
>>    6   0.040522  10.10.20.15 ->  10.10.10.1   TCP 879>  nfs [ACK]
>> Seq=289 Ack=465 Win=17738 Len=0 TSV=3584694 TSER=2438333196
>>    7   0.451636  10.10.20.15 ->  10.10.10.1   NFS V4 COMP Call<EMPTY>
>> PUTFH;SAVEFH SAVEFH;OPEN OPEN;DELEGRETURN DELEGRETURN;Unknown
>
> That looks weird.  Looking at the pcap--ok, the "delegreturn" is a
> mistake, there's no delegreturn there.
>
>>    8   0.451892   10.10.10.1 ->  10.10.20.15  NFS V4 COMP Reply (Call
>> In 7)<EMPTY>  PUTFH;SAVEFH SAVEFH;OPEN OPEN(10008)
>
> That probably means the server is waiting for the client to return a
> delegation.
>
> Either the server's confused about their being a delegation, or the
> client's failing to return one it should?
>
> --b.

All way over my head.  Any way to check in more detail?

thanks.


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com
