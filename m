From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: stuck/hung nfsv4 mounts
Date: Tue, 4 Nov 2008 12:22:23 -0500
Message-ID: <4d569c330811040922s10e5271u33f8163f58987224@mail.gmail.com>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
	 <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
	 <1225742958.2247.128.camel@brian-laptop>
	 <4d569c330811031228r5bb9aefs7a970303910810e2@mail.gmail.com>
	 <1225746764.2247.133.camel@brian-laptop>
	 <4d569c330811031433k7ae18d4enfbda349e8f90a951@mail.gmail.com>
	 <1225761879.2247.207.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:65294 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbYKDRW1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2008 12:22:27 -0500
Received: by an-out-0708.google.com with SMTP id d40so300793and.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Nov 2008 09:22:24 -0800 (PST)
In-Reply-To: <1225761879.2247.207.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 3, 2008 at 8:24 PM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> On Mon, 2008-11-03 at 17:33 -0500, Kevin Coffman wrote:
>> If you can get
>> a packet trace between the client and server during the mount /
>> context negotiation, check the NULL reply from the server for this
>> error code.
>
> Here is the NULL Call from client:
> No.     Time            Time Delta  Source                Destination           Protocol Info
>   8868 20:07:43.933888 0.043671    10.75.22.1            10.75.22.3            NFS      V4 NULL Call (Reply In 8870)
>
> Frame 8868 (606 bytes on wire, 606 bytes captured)
> Ethernet II, Src: AsustekC_e1:65:cc (00:18:f3:e1:65:cc), Dst: Intel_3f:8b:74 (00:d0:b7:3f:8b:74)
> Internet Protocol, Src: 10.75.22.1 (10.75.22.1), Dst: 10.75.22.3 (10.75.22.3)
> Transmission Control Protocol, Src Port: imaps (993), Dst Port: nfs (2049), Seq: 1, Ack: 1, Len: 552
> Remote Procedure Call, Type:Call XID:0x48023eeb
> Network File System
>    [Program Version: 4]
>    [V4 Procedure: NULL (0)]
>    GSS Token: ...
>        GSS Token Length: 483
>        GSS-API Generic Security Service Application Program Interface
>            OID: 1.2.840.113554.1.2.2 (KRB5 - Kerberos 5)
>            krb5_blob: ...
>                krb5_tok_id: KRB5_AP_REQ (0x0001)
>                Kerberos AP-REQ
>                    Pvno: 5
>                    MSG Type: AP-REQ (14)
>                    Padding: 0
>                    APOptions: 20000000 (Mutual required)
>                        .0.. .... .... .... .... .... .... .... = Use Session Key: Do NOT use the session key to encrypt the ticket
>                        ..1. .... .... .... .... .... .... .... = Mutual required: MUTUAL authentication is REQUIRED
>                    Ticket
>                        Tkt-vno: 5
>                        Realm: ILINX
>                        Server Name (Service and Host): nfs/linux.interlinx.bc.ca
>                        enc-part des-cbc-crc
>                    Authenticator des-cbc-crc
>
> Here is the NULL reply from the server:
>
> No.     Time            Time Delta  Source                Destination           Protocol Info
>   8870 20:07:44.062206 0.128081    10.75.22.3            10.75.22.1            NFS      V4 NULL Reply (Call In 8868)
>
> Frame 8870 (262 bytes on wire, 262 bytes captured)
> Ethernet II, Src: Intel_3f:8b:74 (00:d0:b7:3f:8b:74), Dst: AsustekC_e1:65:cc (00:18:f3:e1:65:cc)
> Internet Protocol, Src: 10.75.22.3 (10.75.22.3), Dst: 10.75.22.1 (10.75.22.1)
> Transmission Control Protocol, Src Port: nfs (2049), Dst Port: imaps (993), Seq: 1, Ack: 553, Len: 208
> Remote Procedure Call, Type:Reply XID:0x48023eeb
> Network File System
>    [Program Version: 4]
>    [V4 Procedure: NULL (0)]
>    GSS Context: <DATA>
>    GSS Major Status: 0
>    GSS Minor Status: 0
>    GSS Sequence Window: 128
>    GSS Token: ...
>        GSS Token Length: 114
>        GSS-API Generic Security Service Application Program Interface
>            OID: 1.2.840.113554.1.2.2 (KRB5 - Kerberos 5)
>            krb5_blob: ...
>                krb5_tok_id: KRB5_AP_REP (0x0002)
>                Kerberos AP-REP
>                    Pvno: 5
>                    MSG Type: AP-REP (15)
>                    enc-part des-cbc-crc
>                        Encryption type: des-cbc-crc (1)
>                        enc-part: ...
>
> b.

>From this output, it looks like the response back from the server was
a success.  So it appears to be some other issue.

Perhaps, back to the processes stuck in the kernel?  Unless Trond has
suggestions, I would reboot the client and see if it happens again
(w/o soft mounts).

K.C.
