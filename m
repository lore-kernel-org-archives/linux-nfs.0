Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197Ab2BHSGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 13:06:55 -0500
Message-ID: <4F32B9BB.8030504@netapp.com>
Date: Wed, 08 Feb 2012 13:06:51 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Sven Geggus <lists@fuchsschwanzdomain.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4: ID-mapping Problem with Linux Client and NetApp Server
References: <20120208144923.GA16606@geggus.net> <4F3295CC.7020503@netapp.com> <20120208161212.GA18284@geggus.net>
In-Reply-To: <20120208161212.GA18284@geggus.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/12 11:12, Sven Geggus wrote:

> Bryan Schumaker schrieb am Mittwoch, den 08. Februar um 16:33 Uhr:
> 
>>> [nfsd.rpc.request.bad:warning]: Client 10.1.7.174 is sending bad rpc requests with error: RPC version mismatch or authentication error(73)
>>> [nfsd.auth.status.bad:warning]: Client 10.1.7.174 has an authentication error 2
>>
>> This does look suspicious... using wireshark, can you look at a packet
>> sent by the client to the server. 
> 
> Which one? There are quite a lot (mount only):


Any of the v4 compounds should work.  How about "78.524457   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR"?

> 
>  78.495261   10.1.7.174 -> 10.1.1.14    TCP ns > nfs [SYN] Seq=0 Win=14600 Len=0 MSS=1460 TSV=295718 TSER=0 WS=3
>  78.495763    10.1.1.14 -> 10.1.7.174   TCP nfs > ns [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=1 TSV=2168684 TSER=295718
>  78.495776   10.1.7.174 -> 10.1.1.14    TCP ns > nfs [ACK] Seq=1 Ack=1 Win=14600 Len=0 TSV=295718 TSER=2168684
>  78.495932   10.1.7.174 -> 10.1.1.14    NFS V4 NULL Call
>  78.496314    10.1.1.14 -> 10.1.7.174   NFS V4 NULL Reply (Call In 193)
>  78.496326   10.1.7.174 -> 10.1.1.14    TCP ns > nfs [ACK] Seq=45 Ack=29 Win=14600 Len=0 TSV=295718 TSER=2168684
>  78.499028   10.1.7.174 -> 10.1.1.14    TCP 43936 > nfs [SYN] Seq=0 Win=14600 Len=0 MSS=1460 TSV=295719 TSER=0 WS=3
>  78.499352    10.1.1.14 -> 10.1.7.174   TCP nfs > 43936 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=1 TSV=2168684 TSER=295719
>  78.499673   10.1.7.174 -> 10.1.1.14    TCP 43936 > nfs [ACK] Seq=1 Ack=1 Win=14600 Len=0 TSV=295719 TSER=2168684
>  78.500604   10.1.7.174 -> 10.1.1.14    NFS V4 NULL Call
>  78.501116    10.1.1.14 -> 10.1.7.174   TCP nfs > 43936 [ACK] Seq=1 Ack=1421 Win=67160 Len=0 TSV=2168685 TSER=295719
>  78.513634    10.1.1.14 -> 10.1.7.174   NFS V4 NULL Reply (Call In 199)
>  78.513642   10.1.7.174 -> 10.1.1.14    TCP 43936 > nfs [ACK] Seq=1421 Ack=229 Win=15672 Len=0 TSV=295722 TSER=2168686
>  78.516069   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTROOTFH;GETFH;GETATTR
>  78.516636    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 203) <EMPTY> PUTROOTFH;GETFH;GETATTR
>  78.517697   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.517905   10.1.7.174 -> 10.1.1.14    NFS V4 NULL Call[Malformed Packet]
>  78.518127    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 205) <EMPTY> PUTFH;GETATTR
>  78.518252   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.518378    10.1.1.14 -> 10.1.7.174   NFS V4 NULL Reply (Call In 206)
>  78.518525   10.1.7.174 -> 10.1.1.14    TCP 43936 > nfs [RST, ACK] Seq=1488 Ack=253 Win=15672 Len=0 TSV=295724 TSER=2168686
>  78.518844    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 208) <EMPTY> PUTFH;GETATTR
>  78.518958   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.519388    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 212) <EMPTY> PUTFH;GETATTR
>  78.519511   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.519904    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 214) <EMPTY> PUTFH;GETATTR
>  78.520011   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.520436    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 216) <EMPTY> PUTFH;GETATTR
>  78.521373   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.521945    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 218) <EMPTY> PUTFH;GETATTR
>  78.522067   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.522564    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 220) <EMPTY> PUTFH;GETATTR
>  78.522677   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;ACCESS;GETATTR
>  78.523110    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 222) <EMPTY> PUTFH;ACCESS;GETATTR
>  78.523210   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.523670    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 224) <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.523788   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;ACCESS;GETATTR
>  78.524284    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 226) <EMPTY> PUTFH;ACCESS;GETATTR
>  78.524457   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.528700    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 228) <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.528837   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.533596    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 230) <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.535466   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.536015    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 232) <EMPTY> PUTFH;GETATTR
>  78.536119   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.536611    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 234) <EMPTY> PUTFH;GETATTR
>  78.536730   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.537235    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 236) <EMPTY> PUTFH;GETATTR
>  78.537554   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.538192    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 238) <EMPTY> PUTFH;GETATTR
>  78.538306   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;GETATTR
>  78.538781    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 240) <EMPTY> PUTFH;GETATTR
>  78.538896   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;ACCESS;GETATTR
>  78.539384    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 242) <EMPTY> PUTFH;ACCESS;GETATTR
>  78.539491   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.539987    10.1.1.14 -> 10.1.7.174   NFS V4 COMPOUND Reply (Call In 244) <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR
>  78.577771   10.1.7.174 -> 10.1.1.14    TCP ns > nfs [ACK] Seq=3701 Ack=4177 Win=31752 Len=0 TSV=295739 TSER=2168688
> 
>> Under "Remote Procedure Call", check
>> that check the "Credentials" have kerberos.  
> 
>> Also check the server configuration to make sure that krb5 is allowed and
>> using the DES-CBC-CRC enctype.
> 
> I'm not shure about this. Whatever the Active Directory (2008rc2) default
> is, it should apply.


I have no idea what their default is, but I'm fairly certain only DES and Triple-DES work against OnTap (somebody correct me if I'm wrong, please).

> 
>> The idmapper usually maps users to "nobody" when they don't exist.  My
>> best guess is that your problem has something to do with your kerberos
>> configuration.  Is the client in the keytab?
> 
> How can I check this at the server? 


I'm not sure offhand, my best guess is something under vserver -> nfs -> kerberos-config, but I've never set this up on ontap so that might not be right.

- Bryan

> 
> Kerberos stuff looks fine on the client and it already works fine for nss and
> ssh. I would rather expect some kind of Missconfiguration concerning
> nss/ldap on the server side. 

> 
> Sven
> 


