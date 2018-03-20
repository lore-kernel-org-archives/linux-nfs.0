Return-Path: <jlayton@kernel.org>
Message-ID: <1521547289.4686.2.camel@kernel.org>
Subject: Re: running NFS in LXC
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>, Benjamin Coddington
	 <bcodding@redhat.com>
Cc: Harald Dunkel <harald.dunkel@aixigo.de>, linux-nfs@vger.kernel.org
Date: Tue, 20 Mar 2018 08:01:29 -0400
In-Reply-To: <20180215154516.GB9999@fieldses.org>
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
	 <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
	 <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
	 <F9942544-0C31-4618-BF73-292FF4265C31@redhat.com>
	 <20180215154516.GB9999@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-02-15 at 10:45 -0500, J. Bruce Fields wrote:
> On Wed, Feb 14, 2018 at 09:15:05AM -0500, Benjamin Coddington wrote:
> > On 14 Feb 2018, at 2:06, Harald Dunkel wrote:
> > 
> > > Hi Ben,
> > > 
> > > I take this as a "no serious problems by now". Good to hear.
> > > Which kernel are you using?
> > 
> > This was years ago on a 2.6.32 series.  I don't expect you'll have
> > serious problems now, either.  As far as I know, my last employer is
> > still using that architecture, but I couldn't tell you what software
> > versions they're on now..
> > 
> > We moved to the knfsd-in-a-container from an architecture that was
> > essentially a bunch of vanilla knfsds that could mount and any of
> > the block devices, and block devices were tied to IP addresses, and
> > this was all orchestrated by pacemaker.  The problem with that one
> > was that when a block device or filesystem was migrated, the server
> > receiving that filesystem had to be put into grace, which disrupted
> > any existing NFS serving that was going on.
> > 
> > Test things, let us know how it works!
> 
> I think you were using KVM, right, Ben?
> 
> Harald is talking about LXC, and there are still a few problems there.
> 
> Jeff, do you object to going back to our plan B for reboot recovery (the
> daemon)?  The usermode helper containerization seems stalled and I have
> to admit I'm probably not going to take it on myself.  That might be the
> only knfsd-in-a-container obstacle left.

Sorry for the late response. I've no objection to resurrecting that
approach if it helps this use-case. The daemon and umh callout should be
able to share a lot of the same code and database if it's done properly.

-- 
Jeff Layton <jlayton@kernel.org>
