From: Peter Wainwright <prw@ceiriog1.demon.co.uk>
Subject: Re: Irix NFS servers, again :-)
Date: Thu, 17 Jun 2004 18:44:27 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1087494267.3677.9.camel@ceiriog1.demon.co.uk>
References: <1087411925.30092.35.camel@ceiriog1.demon.co.uk>
	 <40D163C8.30507@greenhydrant.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261396AbUFQSHD@vger.kernel.org>
To: David Rees <drees@greenhydrant.com>
In-Reply-To: <40D163C8.30507@greenhydrant.com>
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2004-06-17 at 10:26, David Rees wrote:

> 
> As I understand it the real problem is actually in glibc.  I have to 
> double check, but I think the software which showed this bug when I 
> experienced it on FC2 was statically linked with an older version of 
> glibc.  I can't seem to reproduce it using `ls` which I remember being 
> able to last time I had the problem so that would explain it.  What 
> software showed the problem for you?

The Gnome configuration daemon, gconfd-2. My desktop configuration
reverted to the default because this program could not find
~/.gconf/apps/panel/profiles/default on an NFS-mounted home
directory.

Peter Wainwright


> 
> See this message from the nfs list.  There is more data in the archives 
> if you look.
> http://marc.theaimsgroup.com/?l=linux-nfs&m=105158098101612&w=2
> 
> -Dave
