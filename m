From: Tobias Diedrich <ranma@gmx.at>
Subject: Re: NFSv3, 2.6, ext3 and dir_index
Date: Sat, 13 Aug 2005 11:39:15 +0200
Message-ID: <20050813093914.GA16767@yamamaya.is-a-geek.org>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu> <1120076887.8751.34.camel@localhost.localdomain> <20050629205056.GB29952@ti64.telemetry-investments.com> <20050120163806.GA25242@melchior.yamamaya.is-a-geek.org> <20050314172234.GA11469@perlsupport.com> <20050320212106.GA5580@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E3uL9-0005qI-8g
	for nfs@lists.sourceforge.net; Sat, 13 Aug 2005 04:38:15 -0700
Received: from lum.tdiedrich.de ([193.24.211.71] ident=postfix)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E3uL7-0000tL-Hy
	for nfs@lists.sourceforge.net; Sat, 13 Aug 2005 04:38:15 -0700
Resent-Message-ID: <20050813113752.GA8772@yamamaya.is-a-geek.org>
To: nfs@lists.sourceforge.net
In-Reply-To: <20050629205056.GB29952@ti64.telemetry-investments.com> <20050320212106.GA5580@yamamaya.is-a-geek.org>
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

Followup for people looking at this thread in the archive:

The patch mentioned in Bills Message seems to be in 2.6.13 release candidates,
however my server is still running 2.6.11.12 (without the patch),
but I'm about to upgrade to 2.6.12.4 (with the patch applied).
Hopefully this will fix both errors I was seeing. :-)

Tobias Diedrich wrote on 20 Mar 2005 in
<20050320212106.GA5580@yamamaya.is-a-geek.org>:
> Sorry for the late reply.
> 
> Chip Salzenberg wrote:
> 
> > Did you ever get any replies on dir_index vs. nfs?
> 
> Not really.
> 
> > I'm just setting up a new server and I'm wondering if there's
> > something still out there that might make me sorry to use dir_index.
> 
> For now I've just disabled dir_index and I haven't had any problems
> since, but I'm not completely sure if that really was the cause of
> the problem I was seeing.  At least disabling dir_index is rather
> easy (remove dir_index featureflag with tune2fs and run e2fsck to
> get rid of the remaining hashtrees).
> Maybe I'll try again to get a proper traffic trace, but I guess I'd
> have to set up a test client first to separate the unrelated nfs traffic.
> 
> -- 
> Tobias						PGP: http://9ac7e0bc.uguu.de

Bill Rugolsky Jr. wrote on 29 Jun 2005 in
<20050629205056.GB29952@ti64.telemetry-investments.com>:
> On Wed, Jun 29, 2005 at 01:28:07PM -0700, Kris Vassallo wrote:
> > I was using ext3, upgraded to core 3 from core 1 and had the exact same
> > problems. What did it for me, until someone fixes this problem, was to
> > turn off journaling (so basically its back to ext2). Since reverting
> > back to ext 2 the problem has gone away. Now this is going to be a huge
> > problem if the machine crashes because fscking a 1.5 TB disk array is
> > going to suck! I experimented with the way the journaling gets done
> > (data goes to disk first or journal first) and I wasn't able to fix the
> > problem. 
> > 
> > Aaaaaaargh! 
> > I just thought I would share my ongoing battle story, hopefully someone
> > will figure out what's causing this and will come up with a fix.
> 
> We're you using ext3 directory indexing? [Look for feature "dir_index" on
> the "Filesystem features:" line in "/sbin/tune2fs -l <device>" output.]
> 
> If so, was the following patch in the kernel that you were using?
> 
>    http://marc.theaimsgroup.com/?l=ext2-devel&m=111568753527230&w=2
> 
> Regards,
> 
> 	Bill Rugolsky

-- 
Tobias						PGP: http://9ac7e0bc.uguu.de


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
