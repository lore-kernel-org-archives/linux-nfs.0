From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/13] RPC server pre-requisites for IPv6
Date: Tue, 30 Jan 2007 16:24:07 +1100
Message-ID: <17854.54903.29418.138244@notabene.brown>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBlTv-000412-A1
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 21:24:35 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBlTw-0006qu-SY
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 21:24:37 -0800
In-Reply-To: message from Chuck Lever on Thursday January 18
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

On Thursday January 18, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Please consider these patches for 2.6.21.  They can replace the similar patch
> set that is currently included in Andrew's kernel.  These patches address a
> few minor bugs, and may fix a problem that Andrew is currently seeing.

Thanks Chuck, and sorry for the delay in getting to then.

Once patches are in Andrew's tree it is really a lot easier to get
incremental patches rather than replacements.  For one thing it makes
review much easier.

I couldn't find anything significant in the first 6 patches of what is
in -mm, so I am ignoring them.  If there is something I missed, please
tell me or send an incremental patch.

The remaining 7 (7..13) look fine. 
I noticed you replacing
  struct sockaddr_in *sin
with
  struct sockaddr *sin
a couple of times and wondered if the name should change with the
type (as 'sin' is really an abbreviation of sockaddr_in).  But figured
it is probably fine as it is.

I'll send them off to Andrew shortly.

How much further do we need to go until kernel-side support for an
IPv6 NFS server is all there?  I'm guessing there are not a lot more
placed that need fixing, but some of them might be big fixes ??

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
