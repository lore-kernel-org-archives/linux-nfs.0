From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/7] fix setuid/setgid clearing in networked
 filesystems (take 6)
Date: Wed, 19 Sep 2007 11:52:50 -0400
Message-ID: <20070919115250.b55a90cc.jlayton@redhat.com>
References: <200709171129.l8HBT5Kq024360@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: reiserfs-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org,
	unionfs@filesystems.org, linux-cifs-client@lists.samba.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-new-b.sourceforge.net ([10.3.1.93]
	helo=sc8-sf-list1-new.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY1rV-0007w4-Ki
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 08:53:13 -0700
In-Reply-To: <200709171129.l8HBT5Kq024360@dantu.rdu.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 17 Sep 2007 07:29:05 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> This patchset is the latest one for fixing the clearing of setuid/setgid
> bits in networked filesystems. It should apply cleanly to 2.6.23-rc4-mm1.
> This is basically the same patchset as take 5. The main differences are
> that the patches have been reordered to make the tree cleanly bisectable,
> and the comment in notify_change is now a bit more descriptive. I've also
> moved the description of the main rationale for the patch into patch 5.
> 
> Andrew, would it be possible to go ahead and get this committed to -mm?
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Andrew,
  This will need some changes before it can apply cleanly to
2.6.23-rc6-mm1. You can ignore this for now. I'll respin, retest and
repost...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
