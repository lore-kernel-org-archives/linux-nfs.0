From: Ion Badulescu <ionut@badula.org>
Subject: Re: (autofs) Re: Direct mounts on Linux
Date: Tue, 21 Jan 2003 17:59:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301212259.h0LMxXj07960@buggy.badula.org>
References: <p5iswjyocn.fsf@lemming.engeast.baynetworks.com>
Cc: nfs@lists.sourceforge.net, Scott Mcdermott <smcdermott@questra.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b7Mx-0006PO-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 14:59:47 -0800
To: "Paul Smith" <pausmith@nortelnetworks.com>
In-Reply-To: <p5iswjyocn.fsf@lemming.engeast.baynetworks.com>
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

On 21 Jan 2003 02:05:28 -0500, Paul Smith <pausmith@nortelnetworks.com> wrote:
> %% Scott Mcdermott <smcdermott@questra.com> writes:
> 
>  >> Well, sure, but there's still getcwd() ... :)
> 
>  sm> which is also kept track of in the shell (talking about bash only,
>  sm> don't know what other shells do)
> 
> No, I mean getcwd(3), the C runtime library function... if my program
> invokes this then it doesn't matter what the shell does.

getcwd() on a modern Linux kernel (2.2 or newer) is a system call so the
library doesn't need to play any tricks with stat() and readdir(). Thus
it doesn't matter how many direct mounts you have.

Of course, this is a Linux-only optimization, other systems will still
have the same old problems if a mount hangs.

As for the direct mount support in am-utils:

- Linux autofs doesn't support direct mounts. Period. It's a kernel
  limitation,   and nothing amd does can work around it. So if you're
  using amd in it's new autofs mode, direct mounts won't work. I think
  we try to emulate them using the non-autofs mode, but read the next
  paragraph...

- The trick amd uses (currently) to provide direct-mounts is rather ugly:
  it mounts a filesystem (its own) and then it claims that the root of 
  that filesystem is a symlink. Crossing that symlink is what triggers
  the automount. The kernel gets rather upset about this, because it
  makes the (rather reasonable) assumption that the root of a filesystem
  is always a directory.

I haven't looked into this for some time, but indeed, the kernel patch we
used to provide stopped working around 2.4.10 or so. Al Viro suggested an
alternative way of implementing direct mounts, using bind mounts, but there
are a few problems with it:

- It's very Linux-specific. Not an insurmountable problem, but a headache
  nonetheless.

- It necessarily needs to know a _lot_ about the kernel internals,
  specifically about the order in which the kernel does calls to the
  filesystem during path_walk() -- and cached_path_walk() -- so that
  we trigger the mount at the right time, not too early and not too late.
  This is bound to break on a lot of kernel versions, and is a nightmare
  to maintain, especially in a package like am-utils that strives to be
  relatively OS-independent.

I'm willing to look over patches that implement the bind-mount alternative,
or I may even do it myself when I get way too much free time on my hands
(heh!).  Nevertheless, due to the above reasons, direct mounts will always
be a second rate citizen on Linux.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
