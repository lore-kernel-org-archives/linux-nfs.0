Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab0JNOIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:08:02 -0400
Date: Thu, 14 Oct 2010 10:08:00 -0400
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Cc: Lyle Seaman <lyleseaman@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: 'Continuation' packets in case of NFS READ.
Message-ID: <20101014140800.GC24146@fieldses.org>
References: <D3F292ADF945FB49B35E96C94C2061B90DAD01D8@nsmail.netscout.com>
 <AANLkTimMm0-Ux+frJq4k0PD5JyR2rMi8Bq9xXYSfjKbB@mail.gmail.com>
 <D3F292ADF945FB49B35E96C94C2061B90DAD0231@nsmail.netscout.com>
 <AANLkTik0neXy5r7TZ3nr8ZT4w8T7oFG2NoySWS73GBYq@mail.gmail.com>
 <D3F292ADF945FB49B35E96C94C2061B90DAD029A@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90DAD029A@nsmail.netscout.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 14, 2010 at 08:30:53AM -0400, Tayade, Nilesh wrote:
> > From: Lyle Seaman [mailto:lyleseaman@gmail.com]
> > Sent: Thursday, October 14, 2010 5:35 PM
> > To: Tayade, Nilesh
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: 'Continuation' packets in case of NFS READ.
> >
> > Sorry, that was imprecise of me.  I ought to have said "it's an RPC
> function".  Distinguishing between the end of one RPC and the next is
> easy with UDP.  For TCP it's done with an end-of-record marker.  See the
> RFCs.  RFC1057 is the one I remember. Maybe there's been an update, but
> that's a good place to start.
> > 
> 
> Sorry, if question is not clear or I am unable to interpret your
> response and cluttering the mailing list. I shall also go through the
> RFC1057.
> What I wanted to know is -
> 
> If I have file1 on mountpoint-1 and file2 on mountpoint-2. Both these
> mount points reside on same server and the respective file size is also
> big. If we look at the packets for these mount point access, we can see
> source port for packet of mount-1 same as that of packet of mount-2
> (Ofcourse, NFS port 2049 will remain same, but the other port used for
> setting up the connection also remains same).
> 
> So if the 'Continuation' chunk comes, how does the client know which
> file it belongs to? The RPC packet doesn't have much info and TCP/UDP
> packets will show same ip-port pair.

If the two mountpoints are sharing the same tcp connection, then the
server will only transmit one RPC reply at a time.  So "chunks" from the
two replies won't be intermingled.

--b.
