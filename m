Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45749 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbbHXUOD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 16:14:03 -0400
Date: Mon, 24 Aug 2015 16:14:01 -0400
To: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 mount fails on Sun Solaris 10 after reboot of client
Message-ID: <20150824201401.GA401@fieldses.org>
References: <201508241452.57718.ulrich.gemkow@ikr.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201508241452.57718.ulrich.gemkow@ikr.uni-stuttgart.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 24, 2015 at 02:52:55PM +0200, Ulrich Gemkow wrote:
> we have a weired problem with Linux NFSv4.0 Server (Vanilla
> Kernel 4.1.6) and a Sun Solaris 10 client (all patches applied):
> 
> When mounting a share on the Solaris client and then rebooting
> the client without unmounting the share first, after the reboot
> every attempt to mount the share again gives an I/O error on
> the client and the mount fails.
> 
> After a long time (serveral hours) the v4 mount suddenly works
> again.
> 
> Mounting a share with vers=2 works always even in times when
> the v4 mount fails.
> 
> So it seems the Linux NFSv4 server holds a state for the client
> which prevents the re-mounting of the share and gives the
> I/O-error on the client.
> 
> We use NFSv4 without idmapd.
> 
> Is there any tip how to debug or solve this?

Best is probably to get a packet trace.  So something like:

	tcpdump -s0 -iem0 -wtmp.pcap

and then try the client mount, then kill the tcpdump after the mount
fails, and send us tmp.pcap.  (And/or take a look at tmp.pcap yourself
with wireshark.  The interesting question is what kind of error the
server is returning when the client tries the mount after reboot.)

--b.

> 
> Thank you and best regards
> 
> -Ulrich
> 
> -- 
> |-----------------------------------------------------------------------
> | Ulrich Gemkow
> | University of Stuttgart, Germany
> | Institute of Communication Networks and Computer Engineering (IKR)
> |-----------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
