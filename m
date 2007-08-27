From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 filesystem mounted via the "bind" option reports wrong
	fstype
Date: Mon, 27 Aug 2007 14:40:59 -0400
Message-ID: <20070827184059.GI3118@fieldses.org>
References: <46D318D3.9020101@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jkar8572@users.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759722AbXH0SlV@vger.kernel.org>
In-Reply-To: <46D318D3.9020101@oxeva.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Aug 27, 2007 at 08:32:51PM +0200, Gabriel Barazer wrote:
> Hi,
> 
> A nfs4 filesystem, mounted elsewhere via the "bind" option (the usual 
> way to do with nfsv4 and its pseudofs), reports wrong fstype "nfs" 
> instead of "nfs4" filesystem.
> An example is much easier to understand :
> Server-side :
> - /exports is the pseudo root filesystem (fsid=0 option in /etc/exports)
> - /exports/data is a mountpoint for another filesystem (not the same 
> device-id as /exports). This condition seems to be what triggers the bug
> - /exports/data must be exported with the "nohide" option (again, the 
> usual way to do se with nfsv4)
> 
> Client-side :
> - mount server:/  on /imports
> - mount "bind" /imports/data on /home/data

There's no reason not to just mount server:/exports/data directly at
/home/data; the bind mounts are just a workaround for the somewhat
primitive exports facility on the server side.

> (this magically shows a second nfs mount in /proc/mounts)
> And here is the bug : this second mount is of fstype "nfs" instead of 
> "nfs4" although the options field contains "vers=4".

But, yes, that sounds like a bug, thanks.

--b.
