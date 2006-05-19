From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: PATCH [1/2] Capture nfsv4 server operations statistics
Date: Fri, 19 May 2006 12:27:47 -0400
Message-ID: <20060519162747.GI3721@fieldses.org>
References: <4469C82B.AD69.00CC.0@novell.com>
	<20060517213638.GE11237@fieldses.org>
	<446E3040.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Shankar Anand <shanand@novell.com>
In-Reply-To: <446E3040.AD69.00CC.0@novell.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, May 19, 2006 at 09:23:20AM -0600, Shankar Anand wrote:
> Verified compilation when nfsv4 is configured out. And also 
> made changes so that the nfsv4 operation statistics are captured
> only when nfsv4 is configured.

Thanks!  Looks fine to me.

One last thing I wonder about--the current /proc/net/rpc/nfsd ends with
lines like:

proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc4 2 4 172

where the two operations counted on the last line are NULL and COMPOUND.
You're appending one more line, to make:

proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc4 2 4 172
proc4ops 37 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0

I like the fact that that doesn't bother the preexisting proc4 line.  On
the other hand, as far as we know nobody's ever used the data on that
line, and it's hard to see how they would in the future (the number of
NULL calls to the server isn't very important), so may it would be
simplest just to replace the proc4 line entirely, as was done on the
client side.

Any strong opinions from anyone else?

--b.
