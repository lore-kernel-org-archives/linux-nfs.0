From: Thomas Moestl <moestl@ibr.cs.tu-bs.de>
Subject: Re: umount() and NFS races in 2.4.26
Date: Sat, 10 Jul 2004 21:50:01 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040710195001.GC800@timesink.dyndns.org>
References: <20040708180709.GA7704@timesink.dyndns.org> <Pine.LNX.4.58.0407101419210.1378@donald.themaw.net> <20040710181912.GA800@timesink.dyndns.org> <Pine.LNX.4.58.0407110323480.20439@donald.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net,
	Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266365AbUGJTti@vger.kernel.org>
To: raven@themaw.net
In-Reply-To: <Pine.LNX.4.58.0407110323480.20439@donald.themaw.net>
List-ID: <nfs.lists.sourceforge.net>

On Sun, 2004/07/11 at 03:25:34 +0800, raven@themaw.net wrote:
> On Sat, 10 Jul 2004, Thomas Moestl wrote:
> > The system in question still uses autofs3. While I believe that the
> > waitq race is also present there (it could probably cause directory
> > lookups to hang, if I understand it correctly), I do not think that
> > any autofs3 code could cause exactly those symptoms that I have
> > observed. For that, it would have to obtain dentries of the file
> > systems that it has mounted, but the old code never does that.
> 
> All autofs has to do is not delete a directory before exiting for this 
> error to occur.

But in that case, the left-over dentry would be an autofs one, would
it not? In our case, the dentries were verified to belong to a NFS
mount that was unmounted by the automounter (that was one of the
symptoms I was referring to). The automounter itself was still
running, and the autofs still mounted.

	- Thomas
