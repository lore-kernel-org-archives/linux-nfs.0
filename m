From: Krzysztof Adamski <k@adamski.org>
Subject: Re: nfs: server not responding, timed out
Date: Sat, 20 Mar 2010 11:42:33 -0400
Message-ID: <1269099753.12826.74.camel@oxygen.netxsys.com>
References: <20100318170603.f6a7f188.dennisn@dennisn.dyndns.org>
	 <4BA2DFC5.1010400@cn.fujitsu.com>
	 <20100319002720.0e93411e.dennisn@dennisn.dyndns.org>
	 <20100319181038.c94fa3c4.dennisn@dennisn.dyndns.org>
	 <20100320105237.1353566e.dennisn@dennisn.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from radon.netxsys.com ([204.16.202.162]:55301 "EHLO
	radon.netxsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0CTPu6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Mar 2010 11:50:58 -0400
Received: from [205.233.151.7] (Oxygen.NetXSys.Com [205.233.151.7])
	by radon.netxsys.com (Postfix) with ESMTPSA id 796B5C0000A2
	for <linux-nfs@vger.kernel.org>; Sat, 20 Mar 2010 11:42:34 -0400 (EDT)
In-Reply-To: <20100320105237.1353566e.dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-03-20 at 10:52 -0400, Dennis Nezic wrote:
> On Fri, 19 Mar 2010 18:10:38 -0400, Dennis Nezic wrote:
> > On Fri, 19 Mar 2010 00:27:20 -0400, Dennis Nezic wrote:
> > > On Fri, 19 Mar 2010 10:21:57 +0800, Bian Naimeng wrote:
> > > > > After upgrading my server (kernel 2.6.19 to 2.6.33, nfs-utils
> > > > > 1.1.0 to 1.2.1/1.1.4/1.1.6), and probably other stuff too), and
> > > > > possibly my client laptop's kernel, I have suddenly started to
> > > > > get these "server X not responding, timed out" errors (on my
> > > > > client), especially (only?) when doing large file transfers.
> > > > > This would lead to input/output errors, and the transfers would
> > > > > fail.
> > > > > 
> > > > > I never noticed any such problems for over two years, using the
> > > > > older versions. The networking (wifi link) hasn't changed.
> > > > > 
> > > > > Usually the file transfer trips and falls over itself near the
> > > > > end
> > > > > -- Ie. it will do 600MB out of 800MB just fine, and then
> > > > > suddently start giving these "timed out" errors, and then crash
> > > > > and burn. At this point, I am forced to "umount -fl" the mount.
> > > > > If I then try to remount it, the server acnowledges my
> > > > > "authenticated mount requests" perfectly fine, but my client
> > > > > (laptop) still appears "hung". After a few minutes, I am able
> > > > > to remount it.
> > > > > 
> > > > > I tried playing with the rsize/wsize/timeo/retrans variables,
> > > > > but none of it seemed to fix the problem.
> > > > > 
> > > > > Any ideas about what has changed? Maybe this is/was a well-known
> > > > > problem? :P
> > > > > 
> > > > 
> > > >   I do not know the what's the reason. And I am not sure the
> > > > followed discussion can fix this problem, but maybe it can help
> > > > you. http://marc.info/?l=linux-nfs&m=123478426412524&w=2
> > > 
> > > Both the patches mentioned in that thread already seem to have been
> > > applied to my kernels. So, although the problem seems related, it
> > > wasn't that bug in particular. The person in that thread was talking
> > > about mounts dying after 5-15minutes, which doesn't happen with me
> > > -- my problem only seems to occur under intense activity.
> > 
> > Hrm. I just noticed that my scp transfers are stalling -- which also
> > didn't used to happen before with my old kernel. No error messages.
> > Ftp transfers work fine. Eek. :S. (Despite the freezing/stalling, my
> > *actual* network connection works perfectly.)
> > 
> > Ideas?
> 
> It seems that changing the mount options from "soft" to "hard" seems to
> "work" -- at least the transfers eventually finish! Although there are
> still stalls of 6-8minutes ... between the 16 syslog error messages:
> "nfs: server XYZ not responding, still trying" and the 16 subsequent
> error messages: "nfs: server XYZ OK". The key difference being that
> with "hard", it is "still trying" rather than "timed out".
> 
> Now why is it stalling for so long?

I can't tell you why, but I had the same problem with NFS server in
2.6.32.*. Try 2.6.31.something to see if the problem goes away.

K

