From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] mount.nfs: fix retry option settings with binary
	mount options
Date: Wed, 9 Apr 2008 16:30:37 -0400
Message-ID: <20080409163037.4937a267@tleilax.poochiereds.net>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com>
	<1206822608-20154-2-git-send-email-jlayton@redhat.com>
	<47FD0447.9030704@RedHat.com>
	<20080409141323.0c594185@barsoom.rdu.redhat.com>
	<47FD15FB.6090208@RedHat.com>
	<20080409153021.3947925b@barsoom.rdu.redhat.com>
	<47FD22F1.4030704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47FD22F1.4030704@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 09 Apr 2008 16:11:29 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> Jeff Layton wrote:
> > 
> > Yes. But like I mentioned in the description, there is a potential
> > corner case here. If someone does a foreground mount and
> > explicitly sets retry=10000 then it will be reset to 2. It's not very
> > likely, but is simple enough to prevent...
> hmm.. I guess... but programing for every single brain dead
> corner case can really make the code more complicated than
> it need to be, which I think is the case here... I think I would
> rather just added the three lines and live that corner case...
> 
> steved.
> 

I don't feel strongly about it either way. If you think the original
method is better then I'm OK with it.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
