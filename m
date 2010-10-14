Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og103.obsmtp.com ([64.18.1.185]:39965 "HELO
	exprod6og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753046Ab0JNL2t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 07:28:49 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: 'Continuation' packets in case of NFS READ.
Date: Thu, 14 Oct 2010 07:26:46 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90DAD0231@nsmail.netscout.com>
In-Reply-To: <AANLkTimMm0-Ux+frJq4k0PD5JyR2rMi8Bq9xXYSfjKbB@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B90DAD01D8@nsmail.netscout.com> <AANLkTimMm0-Ux+frJq4k0PD5JyR2rMi8Bq9xXYSfjKbB@mail.gmail.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "Lyle Seaman" <lyleseaman@gmail.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>From: Lyle Seaman [mailto:lyleseaman@gmail.com]
>Sent: Thursday, October 14, 2010 4:23 PM
>To: Tayade, Nilesh
>Cc: linux-nfs@vger.kernel.org
>Subject: Re: 'Continuation' packets in case of NFS READ.
>
>TCP (or UDP) handles that. It's transparent to NFS.

Thanks for the information. But I also observed that if you mount
multiple mount points 
from same server, the packets for different mount points flow through
the same socket. 

Could you please elaborate how TCP/UDP can differentiate? Is this based
on the sequence number etc.? 

>On Oct 14, 2010 3:50 AM, "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
wrote:
>
>>Hi,
>>
>>I am working on NFS packet capturing for NFS version3 protocol. In one
>>of the scenarios, I tried opening a very big file and in this case the
>>file data was transferred from server to client in several chunks.
>>
>>I observed there were some 'Continuation' RPC payload sent from server
>>to client which carry file data. But even in Wireshark this doesn't
>>decode any other fields apart from the file contents.
>>
>>Could someone please advice how client knows which particular file a
>>specific 'continuation' packet belongs to? The packet doesn't even
have
>>the filehandle/program version data.
>>
>>I have attached the trace file.
>>
>

--
Thanks,
Nilesh



