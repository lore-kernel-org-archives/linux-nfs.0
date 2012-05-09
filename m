Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932519Ab2EIWQq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 18:16:46 -0400
Message-ID: <1336601796.21032.20.camel@serendib>
Subject: RE: [PATCH] nfs-utils: Add a warning to the nfs manpage regarding
 using NFS over UDP on high-speed links
From: Harshula <harshula@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>, Olaf Kirch <okir@suse.de>
Date: Thu, 10 May 2012 08:16:36 +1000
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC064E7E5C8F@IT-1874.Isys.com>
References: <1330406521.9157.16.camel@serendib>
	 <20120228065218.7e110936@tlielax.poochiereds.net>
	 <20120228124646.GA2528@umich.edu>
	 <BC3988C4-CC1A-4DFA-89AE-7046C674A873@oracle.com>
	 <7C4B183F-8357-4D08-B30A-73196954A5D4@oracle.com>
	 <1330913825.9157.61.camel@serendib>
	 <2194470C-5FD9-4317-9A30-2E6C244138D5@oracle.com>
	 <1336525164.21032.9.camel@serendib>
	 <FA8A9A935BFD3A4D8F0CDA1C4F611BCC064E7E5C8F@IT-1874.Isys.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peter!

On Wed, 2012-05-09 at 14:38 -0400, Peter Staubach wrote:
> Hi.
> 
> I thought that we had previously discussed whether or not to include
> this sort of text and had come to the conclusion to not include it
> because the problem is not new or unique to NFS.  It is a general
> networking issue.  Am I remembering incorrectly?

This was from the most recent discussion:
http://article.gmane.org/gmane.linux.nfs/47349
http://article.gmane.org/gmane.linux.nfs/47350

cya,
#

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Harshula Jayasuriya
> Sent: Tuesday, May 08, 2012 8:59 PM
> To: Steve Dickson
> Cc: Jeff Layton; Linux NFS Mailing List; Chuck Lever; Olaf Kirch
> Subject: [PATCH] nfs-utils: Add a warning to the nfs manpage regarding using NFS over UDP on high-speed links
> 
> * Using NFS over UDP on high-speed links such as Gigabit can cause
>   silent data corruption.
> * The man page text was written by Olaf Kirch and committed to (but not
>   upstream):
> https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> Acked-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Olaf Kirch <okir@suse.com>
> ---
>  utils/mount/nfs.man |   81 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 81 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man index 0d20cf0..87e27e1 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -500,6 +500,8 @@ Specifying a netid that uses TCP forces all traffic from the  command and the NFS client to use TCP.
>  Specifying a netid that uses UDP forces all traffic types to use UDP.
>  .IP
> +.B Before using NFS over UDP, refer to the TRANSPORT METHODS section.
> +.IP
>  If the
>  .B proto
>  mount option is not specified, the
> @@ -514,6 +516,8 @@ The
>  option is an alternative to specifying
>  .BR proto=udp.
>  It is included for compatibility with other operating systems.
> +.IP
> +.B Before using NFS over UDP, refer to the TRANSPORT METHODS section.
>  .TP 1.5i
>  .B tcp
>  The
> @@ -1070,6 +1074,83 @@ or
>  options are specified more than once on the same mount command line,  then the value of the rightmost instance of each of these options  takes effect.
> +.SS "Using NFS over UDP on high-speed links"
> +Using NFS over UDP on high-speed links such as Gigabit .BR "can cause 
> +silent data corruption" .
> +.P
> +The problem can be triggered at high loads, and is caused by problems 
> +in IP fragment reassembly. NFS read and writes typically transmit UDP 
> +packets of 4 Kilobytes or more, which have to be broken up into several 
> +fragments in order to be sent over the Ethernet link, which limits 
> +packets to 1500 bytes by default. This process happens at the IP 
> +network layer and is called fragmentation.
> +.P
> +In order to identify fragments that belong together, IP assigns a 16bit 
> +.I IP ID value to each packet; fragments generated from the same UDP 
> +packet will have the same IP ID. The receiving system will collect 
> +these fragments and combine them to form the original UDP packet. This 
> +process is called reassembly. The default timeout for packet reassembly 
> +is
> +30 seconds; if the network stack does not receive all fragments of a 
> +given packet within this interval, it assumes the missing fragment(s) 
> +got lost and discards those it already received.
> +.P
> +The problem this creates over high-speed links is that it is possible 
> +to send more than 65536 packets within 30 seconds. In fact, with heavy 
> +NFS traffic one can observe that the IP IDs repeat after about
> +5 seconds.
> +.P
> +This has serious effects on reassembly: if one fragment gets lost, 
> +another fragment .I from a different packet but with the .I same IP ID 
> +will arrive within the 30 second timeout, and the network stack will 
> +combine these fragments to form a new packet. Most of the time, network 
> +layers above IP will detect this mismatched reassembly - in the case of 
> +UDP, the UDP checksum, which is a 16 bit checksum over the entire 
> +packet payload, will usually not match, and UDP will discard the bad 
> +packet.
> +.P
> +However, the UDP checksum is 16 bit only, so there is a chance of 1 in
> +65536 that it will match even if the packet payload is completely 
> +random (which very often isn't the case). If that is the case, silent 
> +data corruption will occur.
> +.P
> +This potential should be taken seriously, at least on Gigabit Ethernet.
> +Network speeds of 100Mbit/s should be considered less problematic, 
> +because with most traffic patterns IP ID wrap around will take much 
> +longer than 30 seconds.
> +.P
> +It is therefore strongly recommended to use .BR "NFS over TCP where 
> +possible" , since TCP does not perform fragmentation.
> +.P
> +If you absolutely have to use NFS over UDP over Gigabit Ethernet, some 
> +steps can be taken to mitigate the problem and reduce the probability 
> +of corruption:
> +.TP +1.5i
> +.I Jumbo frames:
> +Many Gigabit network cards are capable of transmitting frames bigger 
> +than the 1500 byte limit of traditional Ethernet, typically
> +9000 bytes. Using jumbo frames of 9000 bytes will allow you to run NFS 
> +over UDP at a page size of 8K without fragmentation. Of course, this is 
> +only feasible if all involved stations support jumbo frames.
> +.IP
> +To enable a machine to send jumbo frames on cards that support it, it 
> +is sufficient to configure the interface for a MTU value of 9000.
> +.TP +1.5i
> +.I Lower reassembly timeout:
> +By lowering this timeout below the time it takes the IP ID counter to 
> +wrap around, incorrect reassembly of fragments can be prevented as 
> +well. To do so, simply write the new timeout value (in seconds) to the 
> +file .BR /proc/sys/net/ipv4/ipfrag_time .
> +.IP
> +A value of 2 seconds will greatly reduce the probability of IPID 
> +clashes on a single Gigabit link, while still allowing for a reasonable 
> +timeout when receiving fragmented traffic from distant peers.
>  .SH "DATA AND METADATA COHERENCE"
>  Some modern cluster file systems provide  perfect cache coherence among their clients.
> --
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html


