From: James Pearson <james-p@moving-picture.com>
Subject: Re: Busy inodes after unmount followed by Oops
Date: Fri, 21 May 2004 16:44:28 +0100
Sender: autofs-bounces@linux.kernel.org
Message-ID: <40AE23DC.6C240DAE@moving-picture.com>
References: <3FFE8B28.1E645E4E@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <autofs-bounces@linux.kernel.org>
To: nfs@lists.sourceforge.net, autofs@linux.kernel.org
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

James Pearson wrote:
> 
> There was a long thread a few months ago about this subject:
> 
> http://marc.theaimsgroup.com/?t=106332683300004&r=1&w=2
> 
> and
> 
> http://marc.theaimsgroup.com/?t=106340013500006&r=1&w=2
> 
> I've read the posts but as far as I can tell, I can't find a 'solution'
> to the problem (but I may have missed it in all the posts!)
> 
> I have the same problem with a large number of dual CPU machines running
> 2.4.20 and above that make heavy use of autofs (v4.0.0pre10).
> 
> We get a:
> 
> VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice
> day...
> 
> mesasage, followed some time later by Oops's from kswapd, umount or some
> other user application.
> 
> Is there a 'fix' for this problem?

Just to follow up on my original posting back in January, the problem
above appears to have been solved by using Ian Kent's latest autofs
kernel patch (20040508) from
http://www.kernel.org/pub/linux/daemons/autofs/v4 - we are also running
the latest 4.1.2/4.1.3 automount daemon.

We've been running this patch on over 400 machines for the last 10 or so
days, and have not seen any instance of this 'VFS: Busy inodes after
unmount/Oops' problem above - previously, we would have seen a
significant number of these in the same time scale (and we are still
seeing the problem on machines not using the patch).

Thanks

James Pearson
