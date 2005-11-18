From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] spinlock recursion on inode number mismatches
Date: Fri, 18 Nov 2005 06:42:51 -0500
Message-ID: <437DBE3B.7030304@RedHat.com>
References: <437CFF13.50606@RedHat.com> <1132270232.8017.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
In-Reply-To: <1132270232.8017.2.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:
> Hmm... That will cause us to call make_bad_inode on all errors in
> nfs_update_inode().
Good point... I didn't see that...

> 
> How about something like the appended patch instead?
Yes... creating away for nfs_zap_caches() to be called
while holding the inode spinlock does in deed fix the
problem... nice work... thanks!

steved.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
