Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f44.google.com ([209.85.212.44]:51546 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933827Ab3E1Mbp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 08:31:45 -0400
Received: by mail-vb0-f44.google.com with SMTP id i3so3523982vbh.17
        for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 05:31:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DC99B54B-3C48-49A6-B8C4-1410CA707734@oracle.com>
References: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com>
 <60201423.761959.1365722152352.JavaMail.root@erie.cs.uoguelph.ca>
 <CACQjR_Arj61HJ-QrKfccg=r38555U-43uwhqtwzrN3nd1uUO-Q@mail.gmail.com>
 <CACQjR_CcKwHU8sMrmQ5YfgV5dbuiMLRRqBkDRQEVq2yjGEuzmg@mail.gmail.com> <DC99B54B-3C48-49A6-B8C4-1410CA707734@oracle.com>
From: Bram Vandoren <brambi@gmail.com>
Date: Tue, 28 May 2013 14:31:24 +0200
Message-ID: <CACQjR_D3rFy9dfb4LvywrDi24D0hucvsifXavivJ7UpkEgTLjA@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Hi Rick, Chuck, Bruce,
>> in attachment is a small pcap when a client is in the locked.
>> Hopefully I can reproduce the problem so I can send you a capture
>> during a reboot cycle.
>
> The pcap file confirms that the state IDs and client ID do not appear to match, and do appear on the same TCP connection (in different operations).  I think the presence of the RENEW operations here suggest that the client believes it has not been able to renew its lease using stateful operations like READ.  IMO this is evidence in favor of the theory that the client neglected to recover these state IDs for some reason.
>
> We'll need to see the actual reboot recovery traffic to analyze further, and that occurs just after the server reboots.  Even better would be to see the initial OPEN of the file where the READ operations are failing.  I recognize this is a non-determinstic problem that will be a challenge to capture properly.
>
> Rather than capturing the trace on the server, you should be able to capture it on your clients in order to capture traffic before, during, and after the server reboot.  To avoid capturing an enormous amount of data, both tcpdump and tshark provide options to save the captured network data into a small ring of files (see their man pages).  Once a client mount point has locked, you can stop the capture, and hopefully the ring will have everything we need.

Hi All,
I managed to capture the packets after a reboot. I send the pcap file
to the people in cc (privacy issue, contact me if someone on the list
wants a copy). This is a summary of what happens after a reboot
(perhaps a missed some relevant information):

38:
- client -> server: client executes 3 writes with a stale clientid (A)
- client -> server: RENEW
44:
- server -> client: NFS4ERR_STALE_STATEID  (in reponse to A)
45:
- server -> client: NFS4ERR_STALE_CLIENTID
65:
- client -> server: RENEW
66
- server -> client: NFS4ERR_STALE_CLIENTID
67,85,87,93:
SETCLIENTID/SETCLIENTID_CONFIRM sequence (ok)
78,79:
NFS4STALE_STATEID (reponse to the other 2 writes in A)

98: OPEN with CLAIM_PREVIOUS
107: response to open: NFS4ERR_NO_GRACE (strange?)
after that the client re-opens the files without CLAIM_PREVIOUS option
and they are all succesful.

The client starts using the new stateids except for the files in A.
The server returns a NFS4_STALE_STATEID, the client executes a RENEW
(IMO this should be an OPEN request) and retries the WRITE, the server
returns a NFS4_STALE_STATEID

Server: FreeBSD 9.1 with new NFS server implementation
Client:  Fedora 17, 3.8.11-100.fc17.x86_64

Any clues?

Thanks,
Bram
