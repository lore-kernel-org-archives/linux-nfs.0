From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 filesystem mounted via the "bind" option reports wrong
	fstype
Date: Mon, 27 Aug 2007 15:32:42 -0400
Message-ID: <20070827193242.GJ3118@fieldses.org>
References: <46D318D3.9020101@oxeva.fr> <20070827184059.GI3118@fieldses.org> <20070827191507.GI21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel Barazer <gabriel@oxeva.fr>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	jkar8572@users.sourceforge.net
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761288AbXH0TdB@vger.kernel.org>
In-Reply-To: <20070827191507.GI21089@ftp.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Aug 27, 2007 at 08:15:07PM +0100, Al Viro wrote:
> On Mon, Aug 27, 2007 at 02:40:59PM -0400, J. Bruce Fields wrote:
>  
> > There's no reason not to just mount server:/exports/data directly at
> > /home/data; the bind mounts are just a workaround for the somewhat
> > primitive exports facility on the server side.
> 
> Bullshit.  Bindings are first-class operations on _client_, regardless
> of fs types involved.

I know.  Did I say something to the contrary?

Maybe I was too terse; in more detail: the original poster appears to be
mounting server:/exports/data by first mounting server:/ somewhere and
then bind-mounting the exports/data someplace else.  I couldn't see an
obvious reason they'd be using two steps instead of just performing a
single mount of server:/exports/data.

So my assumption was that this was due to a confused memory of some
server-side setup instructions.  (On the server side, nfs4 export setup
often requires the administrator to do some extra bind mounts which
shouldn't really be necessary.)

--b.
