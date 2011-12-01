From: Dave Kleikamp <dave.kleikamp@oracle.com>
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS
	exports
Date: Wed, 30 Nov 2011 20:22:39 -0600
Message-ID: <4ED6E4EF.7050101@oracle.com>
References: <20111130071319.GA16711@onthe.net.au>
	<1321861008-20611-1-git-send-email-chris@onthe.net.au>
	<20111129082501.GA569@onthe.net.au>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
	<24960.1322643283@redhat.com> <20111201004709.GA26085@onthe.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Latchesar Ionkov <lucho@ionkov.net>, Jan Harkes <jaharkes@cs.cmu.edu>,
	jfs-discussion@lists.sourceforge.net, Dave Kleikamp <shaggy@kernel.org>,
	Eric Van Hensbergen <ericvh@gmail.com>, codalist@TELEMANN.coda.cs.cmu.edu,
	Greg Kroah-Hartman <gregkh@suse.de>, "Myklebust,
	Trond" <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>, CODA FILE SYSTEM <coda@cs.cmu.edu>,
	Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, Ron Minnich <rminnich@sandia.gov>,
	Petr Vandrovec <petr@vandrovec.name>, linux-afs@lists.infradead.org
To: Chris Dunlop <chris@onthe.net.au>
Return-path: <jfs-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20111201004709.GA26085@onthe.net.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=jfs-discussion>
List-Post: <mailto:jfs-discussion@lists.sourceforge.net>
List-Help: <mailto:jfs-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: jfs-discussion-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2011 06:47 PM, Chris Dunlop wrote:
> On Wed, Nov 30, 2011 at 08:54:43AM +0000, David Howells wrote:

...

>>
>> Acked-by: David Howells <dhowells@redhat.com>
>>
>> It's also worth printing a message - this *is* a kernel bug of some description
>> if it happens.
> 
> Like the below?  This covers the d_revalidate for 9p, afs, coda,
> hfs, ncpfs, proc, sysfs.
> 
> Note:  jfs isn't susceptible to this problem, but the resolution
> doesn't look like the other file systems, and from the comment
> I'm not sure if the problem was really understood and if it's
> doing the right thing:

This code, as well as the comments, were copied from vfat. It seems
reasonable for case-insensitive but case-preserving behavior (not jfs's
default). The safe thing is to drop the negative dentry if we don't know
the operation.

> 
> static int jfs_ci_revalidate(struct dentry *dentry, struct nameidata *nd)
> {
>         ...
>         /*
>          * This may be nfsd (or something), anyway, we can't see the
>          * intent of this. So, since this can be for creation, drop it.
>          */
>         if (!nd)
>                 return 0;
> 
>         /*
>          * Drop the negative dentry, in order to make sure to use the
>          * case sensitive name which is specified by user if this is
>          * for creation.
>          */
>         if (nd->flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
>                 return 0;
>         ...
> }
> 
> Chris.
> 

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
