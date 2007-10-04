From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [RFC] [PATCH 1/2] nfs: Fix i_size update in O_DIRECT write
Date: Thu, 04 Oct 2007 11:44:01 +0530
Message-ID: <1191478441.26096.9.camel@jays-ws.blr.novell.com>
References: <1191413953.20470.52.camel@jays-ws.blr.novell.com>
	<4703E929.BANGALORE.BLR1.100.1617768.1.E510.1@1:45C9E2C2.BANGALORE.BLR.100.1617768.1.11D54.1@13>
	<1191423807.20470.107.camel@jays-ws.blr.novell.com>
	<47047294.BANGALORE.BLR1.100.1617768.1.E570.1@1:7.BANGALORE.BLR1.100.0.1.0.1@16>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdJtg-0002RN-TA
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 23:09:21 -0700
Received: from victor.provo.novell.com ([137.65.250.26])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdJtk-0003vU-SF
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 23:09:26 -0700
In-Reply-To: <47047294.BANGALORE.BLR1.100.1617768.1.E570.1@1:7.BANGALORE.BLR1.100.0.1.0.1@16>
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

On Wed, 2007-10-03 at 19:21 -0400, Trond Myklebust wrote:
> On Wed, 2007-10-03 at 20:33 +0530, Suresh Jayaraman wrote:
> > On Wed, 2007-10-03 at 09:35 -0400, Trond Myklebust wrote:
> > > On Wed, 2007-10-03 at 17:49 +0530, Suresh Jayaraman wrote:

> I fully agree that the current code is messy, but I've just spent the
> last 2 weeks working on a set of cleanups that will hopefully make it
> much less confusing, and a lot more accurate. ...and yes, the above two
> code snippets that you point out are among those slated for removal.

Ah, I should have checked nfs-2.6.git. Yes, the changes look pretty good
and lot less confusing.

> Please could you have a look at the patchsets on
>   http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc9/

These two patches fix the issue.

http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc9/linux-2.6.23-079-optimise_nfs_update_inode.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc9/linux-2.6.23-090-remove_bogus_check_in_nfs_update_inode.dif


Thanks a lot!
-- 
Suresh Jayaraman


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
