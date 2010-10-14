Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og104.obsmtp.com ([64.18.1.187]:53892 "HELO
	exprod6og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751061Ab0JNMch convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 08:32:37 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: 'Continuation' packets in case of NFS READ.
Date: Thu, 14 Oct 2010 08:30:53 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90DAD029A@nsmail.netscout.com>
In-Reply-To: <AANLkTik0neXy5r7TZ3nr8ZT4w8T7oFG2NoySWS73GBYq@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B90DAD01D8@nsmail.netscout.com><AANLkTimMm0-Ux+frJq4k0PD5JyR2rMi8Bq9xXYSfjKbB@mail.gmail.com><D3F292ADF945FB49B35E96C94C2061B90DAD0231@nsmail.netscout.com> <AANLkTik0neXy5r7TZ3nr8ZT4w8T7oFG2NoySWS73GBYq@mail.gmail.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "Lyle Seaman" <lyleseaman@gmail.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> From: Lyle Seaman [mailto:lyleseaman@gmail.com]
> Sent: Thursday, October 14, 2010 5:35 PM
> To: Tayade, Nilesh
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: 'Continuation' packets in case of NFS READ.
>
> Sorry, that was imprecise of me.  I ought to have said "it's an RPC
function".  Distinguishing between the end of one RPC and the next is
easy with UDP.  For TCP it's done with an end-of-record marker.  See the
RFCs.  RFC1057 is the one I remember. Maybe there's been an update, but
that's a good place to start.
> 

Sorry, if question is not clear or I am unable to interpret your
response and cluttering the mailing list. I shall also go through the
RFC1057.
What I wanted to know is -

If I have file1 on mountpoint-1 and file2 on mountpoint-2. Both these
mount points reside on same server and the respective file size is also
big. If we look at the packets for these mount point access, we can see
source port for packet of mount-1 same as that of packet of mount-2
(Ofcourse, NFS port 2049 will remain same, but the other port used for
setting up the connection also remains same).

So if the 'Continuation' chunk comes, how does the client know which
file it belongs to? The RPC packet doesn't have much info and TCP/UDP
packets will show same ip-port pair.


--
Thanks,
Nilesh
