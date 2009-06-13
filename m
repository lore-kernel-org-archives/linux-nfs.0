From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Invalid mount option values should fail even with
 "sloppy"
Date: Sat, 13 Jun 2009 18:13:54 -0400
Message-ID: <1244931234.6803.18.camel@heimdal.trondhjem.org>
References: <20090612221659.25437.19858.stgit@isabey.1015granger.net>
	 <1244912830.6803.4.camel@heimdal.trondhjem.org>
	 <984DFA28-DDFB-46F5-BD2B-16DCB80C7137@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39243 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZFMWNz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Jun 2009 18:13:55 -0400
In-Reply-To: <984DFA28-DDFB-46F5-BD2B-16DCB80C7137@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-06-13 at 17:55 -0400, Chuck Lever wrote:
> On Jun 13, 2009, at 1:07 PM, Trond Myklebust wrote:
> 
> > On Fri, 2009-06-12 at 18:19 -0400, Chuck Lever wrote:
> >> Ian Kent reports:
> >>
> >> "I've noticed a couple of other regressions with the options vers
> >> and proto option of mount.nfs(8).
> >>
> >> The commands:
> >>
> >> mount -t nfs -o vers=<invalid version> <server>:/<path> /<mountpoint>
> >> mount -t nfs -o proto=<invalid proto> <server>:/<path> /<mountpoint>
> >>
> >> both immediately fail.
> >>
> >> But if the "-s" option is also used they both succeed with the
> >> mount falling back to defaults (by the look of it).
> >>
> >> In the past these failed even when the sloppy option was given, as
> >> I think they should. I believe the sloppy option is meant to allow
> >> the mount command to still function for mount options (for example
> >> in shared autofs maps) that exist on other Unix implementations but
> >> aren't present in the Linux mount.nfs(8). So, an invalid value
> >> specified for a known mount option is different to an unknown mount
> >> option and should fail appropriately."
> >>
> >> See RH bugzilla 486266.
> >>
> >> Address the problem by separating parsing errors into two categories.
> >> Invalid options will fail only if sloppy isn't set, but invalid
> >> values will always fail.
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >>
> >> Trond-
> >>
> >> Request For Comments only.  Ian hasn't tested this yet, but I was  
> >> hoping
> >> it could find its way into 2.6.31 at some point, if it looks  
> >> correct to
> >> you.
> >>
> >> fs/nfs/super.c |   57 ++++++++++++++++++++++++++++++ 
> >> +-------------------------
> >> 1 files changed, 32 insertions(+), 25 deletions(-)
> >>
> >> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> >> index 66ffd5d..e88c527 100644
> >> --- a/fs/nfs/super.c
> >> +++ b/fs/nfs/super.c
> >> @@ -957,7 +957,7 @@ static int nfs_parse_mount_options(char *raw,
> >> 				   struct nfs_parsed_mount_data *mnt)
> >> {
> >> 	char *p, *string, *secdata;
> >> -	int rc, sloppy = 0, errors = 0;
> >> +	int rc, sloppy = 0, invalid_options = 0, invalid_values = 0;
> >
> > Why add a counter? Why not just add a variable to hold the return  
> > value
> >
> >          int ret = 0;
> >
> > ...and have the invalid values set ret=1?
> 
> That would probably work for invalid values, which should always cause  
> a failure.  I guess I preferred treating the two as similarly as  
> possible until the logic at the end.  That seemed a little more clear  
> to me.

They're really quite different. In the case of an invalid value, you
know that you can immediately exit the parser and return an error,
whereas in the case of an unknown option you have to continue parsing
until you know whether or not 'sloppy' has been set.

> We still need to sort invalid options if sloppy is set.  Renaming the  
> variable @errors seems like a good way to document what exactly we're  
> counting.

Agreed.

Cheers
  Trond

