From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: [PATCH 1/4] Optimize NFS open() calls by means of 'intents'...
Date: Fri, 23 May 2003 12:32:14 -0600
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20030523123214.H16920@schatzie.adilger.int>
References: <16078.6093.339198.108592@charged.uio.no> <Pine.LNX.4.44.0305230911160.21297-100000@home.transmeta.com> <20030523175954.GD14406@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>,
	"Peter J. Braam" <braam@clusterfs.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: viro@parcelfarce.linux.theplanet.co.uk
In-Reply-To: <20030523175954.GD14406@parcelfarce.linux.theplanet.co.uk>; from viro@parcelfarce.linux.theplanet.co.uk on Fri, May 23, 2003 at 06:59:54PM +0100
List-ID: <nfs.lists.sourceforge.net>

On May 23, 2003  18:59 +0100, viro@parcelfarce.linux.theplanet.co.uk wrote:
> On Fri, May 23, 2003 at 09:23:33AM -0700, Linus Torvalds wrote:
> > 
> > On Fri, 23 May 2003, Trond Myklebust wrote:
> > > Minor cleanup of open() code. Put the original open flags, mode, etc. into
> > > an 'opendata' structure that can be passed as an intent to lookup.
> > 
> > I don't mind the concepts, but I _really_ dislike the implementation.
> > 
> > For one thing, if you're creating a structure to pass in the flags for 
> > open, then you should take the time to make the code _more_ readable 
> > rather than less. In particular, the notion of having a structure like 
> > this:
> > 
> > 	struct opendata {
> > 		int flag;
> > 		int mode;
> > 		int acc_mode;
> > 	};
> > 
> > where each of "flag" and "acc_mode" are magic bitfields just fills me with
> > horror. 
> > 
> > So why not make those internal modes that we translate the "flags" into be 
> > a real bitmap? That should make the code a lot more readable.
> > 
> > Also, I don't really understand why you want to have "opendata" and 
> > "intent" as different structures. That's _especially_ true now that the 
> > only intent is the "open" intent, but even if there were other intents, 
> > I'd rather have something like this
> > 
> > 	struct lookup_info {
> > 		enum type; /* open, validate, whatever.. */
> > 		union {
> > 			struct open_intent open;
> > 			..
> > 		} data;
> > 	}
> > 
> > and gace tge flags (create/exclusive etc) inside that lookup_intent 
> > instead of having multiple different pointers and transferring data from 
> > one to the other at different phases of the "open".
> 
> 
> Linus, that was one of the reasons why struct nameidata had been introduced
> in the first place.  _And_ discussed with Peter, BTW, so I've no idea
> where the hell does lookup_info come from.

Yes, that is where Lustre puts the intent data already in 2.5.  The code
that Trond submitted is AFAICS totally different than what we have been
using for Lustre, but I don't know if Trond and Peter have been discussing
this in private or not.  I've CC'd Peter on this email, although I imagine
he is already getting it by way of fsdevel - he's just in a different
timezone right now.

> Peter, Trond: please fold that stuff into struct nameidata (note that
> flags are already there) and pass the pointer to it into methods.
> That would have an extra benefit (also discussed before) of allowing to
> bring credentials into the game - we could store them in the same place.
> 
> If we are up to changing method prototypes - let's do it properly.

Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://www-mddsp.enel.ucalgary.ca/People/adilger/

