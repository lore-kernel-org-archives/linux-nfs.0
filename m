From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 22:26:57 -0700
Message-ID: <OF18F79283.D2B8D52F-ON882572CB.001C23A2-882572CB.001DE21A@us.ibm.com>
References: <17970.53957.677739.642780@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Jeff Layton <jlayton@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>,
	nfs-bounces@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <17970.53957.677739.642780@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

nfs-bounces@lists.sourceforge.net wrote on 04/27/2007 09:51:17 PM:

> On Friday April 27, wcheng@redhat.com wrote:
> > Frank van Maarseveen wrote:
> > >
> > >I'd prefer (2) "echo /some/path > /proc/fs/nfsd/nlm_drop_lock" 
because:
> > > 
> > >
> > To convert the first patch of this submitted series from "fsid" to 
> > "/some/path" is a no-brainer, since we had gone thru several rounds of 

> > similar changes. However, my questions (it is more of a Neil's 
question) 
> > are, if I convert the first patch to do this,
> > 
> > 1) then why do we still need the RPC drop-lock call in nfs-util ?
> 
> Maybe we don't.
> I can imagine a (probably hypothetical) situation where you want to
> drop some but not all of the locks on a filesystem - if it is a
> cluster-aware filesystem that several virtual-NAS's export, and you
> want to move just one virtual-NAS.  But if you don't want to be able
> to do that, you obviously don't have to.

It would be very useful for cluster filesystems, that can export the same 
filesystem from few servers using multiple IP addresses from each server, 
to be able to move IP address among server for load balancing. 
Marc.
 
> > 2) what should we do for the 2nd patch ? i.e., how do we communicate 
> > with the take-over server it is time for its action, by RPC call or by 

> > "echo /some/path > /proc/fs/nfsd/nlm_set_grace_or_whatever" ?
> 
> I'm happy with using a path name like this to restart the grace
> period.  Where would you store the per-filesystem grace-period-end??
> I guess you would need a new little data structure indexed by
> ... 'struct super_block *' I guess.  It would need to hold a reference
> on the superblock until the grace period expired would it?
> 
> It might seem 'obvious' to store it in 'struct svc_export', but there
> can be several of these per filesystem, and more could be added after
> you set the grace period.  So it would be messy to get that right.
> 
> 
> > 
> > In general, I feel if we do this "/some/path" approach, we may as well 

> > simply convert the 2nd patch from "fsid" to "/some/path". Then we 
would 
> > finish this long journey.
> 
> Certainly a lot closer.
> If we are creating "nlm_drop_locks" and "nlm_set_grace" interfaces, we
> should spend a few moments considering exactly what semantics they
> should have.
> 
> In both cases we write a filename.  Presumably it must start with a
> '/' and be null terminated, so you use "echo -n" rather than "echo".
> After all, a filename can contain a newline.
> 
> Is there any extra info we might want to pass in or out at the same
> time?
> 
> For nlm_drop_locks, we might also want to be able to query locked -
> "Do you hold any locks on this filesystem".  Even "how many?".
> For set_grace, we might want to ask how many seconds are left in the
> grace period (I'm not sure how this info would be used, but it is
> always nice to be able to read any value that you can write).
> 
> Does it make sense to have a single file with composite semantics?
> 
> We write
>     XX/path/name
> where XX can be:
>     a number, to set second remaining in grace period
>     a '?' (or empty string) to query state
>     a '-' to remove all locks (and cancels any grace period)
> We then read back two numbers, the seconds remaining in the grace
> period, and the number of locked files.
> 
> Then we need to make sure we choose appropriate names.  I think that
> the string 'lockd' make more sense than 'nlm', as we are interacting
> with the daemon, not configuring the protocol.  We might not either
> need either as the file is inside /proc/fs/nfsd, it is obviously
> related to nfsd.
> And if we can use the interface to query, then names like 'set' and
> 'drop' and probably mis-placed.  Maybe "grace" and "locks".
> If no path is given, the requests have system-wide effect.  If there
> is a non-empty path, just that filesystem if queried/modified.
> 
> These are just possibilities.  I'm quite happy with either 1 or 2
> files.  I just want to be sure a number of options have been
> considered, and that a reasoned choice as been made.
> 
> NeilBrown
> 
> 
-------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
