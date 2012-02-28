Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965081Ab2B1TqA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 14:46:00 -0500
Date: Tue, 28 Feb 2012 14:45:58 -0500
To: Louie <snikrep@gmail.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: v4recovery client id lockup
Message-ID: <20120228194558.GA2723@fieldses.org>
References: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
 <20120223115206.662b325c@redhat.com>
 <CAMgFM3DgWBSUsoSzcvn=2V+eFwj6wUdmb-XQjyyXGfCq9GD-=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMgFM3DgWBSUsoSzcvn=2V+eFwj6wUdmb-XQjyyXGfCq9GD-=A@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 24, 2012 at 01:08:54PM -0800, Louie wrote:
> Thanks for the help, I think I've tracked this down in case anybody
> else ever runs into same issue.
> 
> We have multiple clients connecting via SSH tunnels, so all NFS
> traffic is routed through localhost (127.0.0.1) on these open ports.
> 
> The problem appears to be the NFS server only partially recognizing
> diff. between these clients through local tunnels. Upon each
> alternating connection, the /var/lib/nfs/rpc_pipefs/nfsd4_cb/clntID
> directory is replaced with a new one (shows the same IP address of
> 127.0.0.1, but a new port). The v4recovery client's hash directory is
> removed/replaced with the exact same hash. Obviously, when multiple
> clients are hitting the box at the same time, this causes a lockup.
> 
> I'm guessing there is no solution and our setup just isn't supported.
> I'm leaning towards ditching the SSH tunnels and going with
> unencrypted traffic for now, as it's not strictly necessary. But if
> anybody has a tip on how to fix, would love to hear.

That's very strange: those directory names are created as a hash of the
clientid that the client sends in setclientid.

Hm, but the linux client generates those using its idea of its IP and
the server's IP, and maybe those both end up being the same for all your
clients.  Giving each client mount command a distinct cilentaddr= option
might help?

And I also wonder if the server's doing the right thing here--could be
it should be returning a clientid_inuse error to most of the clients
instead of whatever it's currently doing (probably assuming it has one
client that's rebooting continually)--but it may be hard for it to tell
the difference.

--b.
