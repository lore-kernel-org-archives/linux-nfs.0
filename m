From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 10:28:10 -0500 (EST)
Message-ID: <200801041528.KAA18776@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: jeff@garzik.org
Return-path: <nfsv4-bounces@linux-nfs.org>
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

> Plus, surely in this day and age, we can figure out something better 
> than waiting for face-to-face events to test something.  Maybe somebody 
> could arrange a donation of some slice of a grid (Amazon EC2?), make 
> various OS images available, and give engineers some way to request a 
> selection of tests, with a selection of OS images?

I tried putting a server up accessible over the internet and only ever
got one person testing on it once (or maybe it was just a hacker:-). I
did test my client against a server at CITI once, after signing a
bakeathon NDA. But, I agree, and I don't really think it even needs
a central site. I don't see why vendors couldn't put up servers
(production software or whatever they are comfortable having internet
 accessible) that clients can test against. I'll be happy to put my
server up and I'd be happy to test against internet accessible servers
with my client.

And, like you, I don't get to connectathon since I don't "make a living
at this" (to loosely quote another poster).

rick
Btw: You might want to post to nfsv4@ietf.org w.r.t. interoperability
     testing, since that will catch people who don't lurk on this list.
