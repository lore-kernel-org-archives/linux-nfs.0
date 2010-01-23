From: Peter Chacko <peterchacko35@gmail.com>
Subject: Re: nfs client performance while server is down
Date: Sat, 23 Jan 2010 21:27:44 +0530
Message-ID: <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Whoop Whouzer <tiredandnumb@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:35928 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755518Ab0AWQEV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jan 2010 11:04:21 -0500
Received: by ywh6 with SMTP id 6so1935786ywh.4
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2010 08:04:18 -0800 (PST)
In-Reply-To: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Which client OS you observed this behavior ?  This has nothing to do
NFS design, and its purely stateless...Its upto the client OS
implementation about aspects like how to deal with local IO, when NFS
share gets  disconnected..

May be a VFS bug on the local OS you found this problem ..

thanks

On Sat, Jan 23, 2010 at 9:15 PM, Whoop Whouzer <tiredandnumb@gmail.com>=
 wrote:
> Howdy,
>
> I was wondering why nfs is designed in such a way that the performanc=
e
> of an nfs client machine gets very bad when the nfs server is offline=
?
> This is even the case with a soft mount (either via mount or fstab).
> Just about every application that requires disk access (not talking
> about nfs share acces) gets really slow to unresponsive. For instance
> nautilus becomes unresponsive when displaying the contents of any
> folder on the local disk,
> playing movie files (stored on local disk) let totem or vlc get stuck
> on set intervals, even the terminal becomes unresponsive at times.
>
> I could understand that these problems would occur while accessing th=
e
> nfs share directoiourry while the server is offline, but why for tota=
lly
> unrelated directories?
>
> I have experienced this behaviour on various distro's, and also found
> various bug reports on this issue, they don't seem to get solved as
> this is viewed as nfs design.
> I see this as a flaw because clients are totally dependent on the
> server. This would be less of a deal if the entire home directory
> would be stored on nfs (although I even think some sort of
> synchronisation technology could and should be implemented in this
> case). It is a bit odd that (technically) one machine serving some
> "useless" files to a non-trivial directory on client machines can tak=
e
> down these client machines.
>
> For me the preferred functionality would be:
> *If an nfs server gets offline the client's nfs share becomes
> unaccessible, but local directories and applications (that only
> require local disk access) stay responsive.
> *If an nfs server gets online (after being offline while the client
> has not been restarted) the nfs share becomes reconnected.
>
> regards,
> Whoop
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
