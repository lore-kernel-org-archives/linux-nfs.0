From: Nick Piggin <npiggin@suse.de>
Subject: Re: Announce: new-aops-1 for 2.6.21-rc3
Date: Thu, 15 Mar 2007 20:57:57 +0100
Message-ID: <20070315195757.GB19625@wotan.suse.de>
References: <20070315161704.GH8321@wotan.suse.de>
	<20070315195351.GE21942@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: jfs-discussion@lists.sourceforge.net, xfs@oss.sgi.com,
	cluster-devel@redhat.com, reiserfs-list@namesys.com,
	nfs@lists.sourceforge.net,
	Linux Filesystems <linux-fsdevel@vger.kernel.org>,
	linux-ext4@vger.kernel.org
To: Mark Fasheh <mark.fasheh@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-new-b.sourceforge.net ([10.3.1.93]
	helo=sc8-sf-list1-new.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRw5N-00012A-0O
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 12:58:07 -0700
In-Reply-To: <20070315195351.GE21942@ca-server1.us.oracle.com>
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

On Thu, Mar 15, 2007 at 12:53:51PM -0700, Mark Fasheh wrote:
> On Thu, Mar 15, 2007 at 05:17:04PM +0100, Nick Piggin wrote:
> > OK, I've gone through and fixed several bugs until the thing actually
> > survives fsx-linux for both ext2 and ext3 ordered and writeback (both
> > when using the new aops, and the legacy prepare_write path). Actually
> > ext3 sometimes breaks, but it does in unpatched kernels anyway.
> > 
> > At 15 patches (including the initial buffered write deadlock fixes),
> > it is too much to keep posting -- not much has fundamentally changed,
> > so I'll just post occasionally if we make big changes. The quilt
> > format is probably easier for someone wishing to work on it anyway.
> 
> Hmm, we still left out some exports...

Thanks, applied.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
