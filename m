From: Chris Dunlop <chris@onthe.net.au>
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS
	exports
Date: Thu, 1 Dec 2011 14:33:47 +1100
Message-ID: <20111201033346.GA1049@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au>
	<1321861008-20611-1-git-send-email-chris@onthe.net.au>
	<20111129082501.GA569@onthe.net.au>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
	<24960.1322643283@redhat.com> <20111201004709.GA26085@onthe.net.au>
	<4ED6E4EF.7050101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Latchesar Ionkov <lucho@ionkov.net>, Jan Harkes <jaharkes@cs.cmu.edu>,
	jfs-discussion@lists.sourceforge.net, Dave Kleikamp <shaggy@kernel.org>,
	Eric Van Hensbergen <ericvh@gmail.com>, codalist@TELEMANN.coda.cs.cmu.edu,
	Greg Kroah-Hartman <gregkh@suse.de>, "Myklebust,
	Trond" <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>,
	CODA FILE SYSTEM <coda@cs.cmu.edu>, maintainer@onthe.net.au,
	Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, Ron Minnich <rminnich@sandia.gov>,
	Petr Vandrovec <petr@vandrovec.name>, linux-afs@lists.infradead.org
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Return-path: <jfs-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <4ED6E4EF.7050101@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=jfs-discussion>
List-Post: <mailto:jfs-discussion@lists.sourceforge.net>
List-Help: <mailto:jfs-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: jfs-discussion-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 30, 2011 at 08:22:39PM -0600, Dave Kleikamp wrote:
> On 11/30/2011 06:47 PM, Chris Dunlop wrote:
>>> It's also worth printing a message - this *is* a kernel bug of some description
>>> if it happens.
>> 
>> Like the below?  This covers the d_revalidate for 9p, afs, coda,
>> hfs, ncpfs, proc, sysfs.
>> 
>> Note:  jfs isn't susceptible to this problem, but the resolution
>> doesn't look like the other file systems, and from the comment
>> I'm not sure if the problem was really understood and if it's
>> doing the right thing:
> 
> This code, as well as the comments, were copied from vfat. It seems
> reasonable for case-insensitive but case-preserving behavior (not jfs's
> default). The safe thing is to drop the negative dentry if we don't know
> the operation.

In that case, it looks like the thing to do might be to add the
"protection" to the start of jfs_ci_revaliate(), per how the
original has been changed in vfat:

fs/fat/namei_vfat.c:
static int vfat_revalidate_ci(struct dentry *dentry, struct nameidata *nd)
{
        if (nd && nd->flags & LOOKUP_RCU)
                return -ECHILD;
        ...
}

E.g.:

----------------------------------------------------------------------
Don't oops when abused by broken layered file systems

Signed-off-by: Chris Dunlop <chris@onthe.net.au>
---
 fs/jfs/namei.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
index e17545e..5504f6e 100644
--- a/fs/jfs/namei.c
+++ b/fs/jfs/namei.c
@@ -1585,6 +1585,9 @@ out:
 
 static int jfs_ci_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
+	if (nd && nd->flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	/*
 	 * This is not negative dentry. Always valid.
 	 *
-- 
1.7.0.4

----------------------------------------------------------------------

------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
