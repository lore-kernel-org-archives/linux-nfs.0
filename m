From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [Linux-cluster] [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 23:39:31 -0400
Message-ID: <1150169971.27203.1.camel@localhost.localdomain>
References: <9A6FE0FCC2B29846824C5CD81C6647B902207776@s228130hz1ew08.apptix-01.savvis.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	linux clustering <linux-cluster@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpzaH-0003kj-KF
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:28:53 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpzaH-0006NB-Ix
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:28:53 -0700
To: "Stanley, Jon" <Jon.Stanley@savvis.net>
In-Reply-To: <9A6FE0FCC2B29846824C5CD81C6647B902207776@s228130hz1ew08.apptix-01.savvis.net>
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

On Mon, 2006-06-12 at 09:45 -0500, Stanley, Jon wrote:
>  
> > -----Original Message-----
> > From: linux-cluster-bounces@redhat.com 
> > [mailto:linux-cluster-bounces@redhat.com] On Behalf Of Wendy Cheng
> > Sent: Monday, June 12, 2006 12:26 AM
> > To: nfs@lists.sourceforge.net
> > Cc: linux-cluster@redhat.com
> > Subject: [Linux-cluster] [RFC] NLM lock failover admin interface

Jon, Thank you for review this - it helps !

-- Wendy

> > 
> > 1. /proc interface, say writing the fsid into a /proc directory entry
> > would end up dropping all NLM locks associated with the NFS 
> > export that
> > has fsid in its /etc/exports file.
> 
> This would defintely have it's advantages for people who know what
> they're doing - they could drop all locks without unexporting the
> filesystem.  However, it also gives people the opportunity to shoot
> themselves in the foot - by eliminating locks that are needed.  After
> weighing the pros and cons, I really don't think that any method
> accessible via /proc is a good idea.
> 
> > 
> > 2. Adding a new flag into "exportfs" command, say "h", such that
> > 
> >    "exportfs -uh *:/export_path"
> > 
> > would un-export the entry and drop the NLM locks associated with the
> > entry.
> > 
> 
> This is the best of the three, IMHO.  Gives you the safety of *knowing*
> that the filesystem was unexported before dropping the locks, and
> preventing folks from shooting themselves in the foot.
> 
> The other option that was mentioned, a separate lockd for each fs, is
> also a good idea - but would require a lot of coding no doubt, and
> introduce more instability into what I already preceive as an unstable
> NFS subsystem in Linux (I *refuse* to use Linux as an NFS server and
> instead go with Solaris - I've had *really* bad experiences with Linux
> NFS under load - but that's getting OT).
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
