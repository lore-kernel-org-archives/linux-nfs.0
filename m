From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.20+NFS_ALL mount hanging, procs stuck in D state
Date: Mon, 24 Feb 2003 19:07:39 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0301161226270.26507-100000@bolt.sonic.net>
References: <shshec9p7zs.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a.smtp-out.sonic.net ([208.201.224.38])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18nVRU-0000WJ-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Feb 2003 19:07:40 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shshec9p7zs.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 16 Jan 2003, Trond Myklebust wrote:

> >>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:
>
>      > Although I am seeing a large number of "hw tcp v4 csum failed"
>      > errors on this host (running e100 driver), I have also seen
>      > smaller numbers of these errors on another host, same kernel,
>      > running the tg3 network driver and not experiencing this
>      > hang. Still, this looks like an NFS client problem.
>
> I disagree: it looks like a hardware problem. From what I can see from
> your RPC dump, the NFS client is treating what it is getting from the
> server as if it were junk data. This is what I would expect to occur
> if the server and client RPC streams are getting desynchronized due to
> data corruption.
>
> Try using the eepro100 driver and/or a different card.

Since then we have seen this problem occur over and over again on a
certain set of hosts and ended up tracing the problem to a bad switch
trunking. Different cables, different cards, different drivers, same
result: total hang of mount on the client and processes sticking in
unkillable D state. Once we took the bad trunk out of the equation,
everything works fine now.

What is really interesting to me is this *same* problem occurred with a
UDP mount as well. I got very similar NFS debug messages to what I
previously posted with TCP.

According to subsequent messages in this thread, bad network data can
sometimes hang TCP mounts, but I got the same effect on UDP. Which
shouldn't happen, right? That would imply that something isn't right in
the linux NFS client.

By the way, other than this, 2.4.20+NFS_ALL has been stellar! The TCP
support is great, we are maxing out our clients at 100Mb day in and day
out and not seeing any problems so far, performance and reliability have
been very good (knock on wood, praise be to Zeus, mighty may he reign,
etc.).


thanks,
andrew



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
