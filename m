From: Karel Zak <kzak@redhat.com>
Subject: Re: [PATCH 11/11] nfs-utils: mount: Fixed collision between
	commas in options
Date: Tue, 27 Feb 2007 12:45:11 +0100
Message-ID: <20070227114511.GF3954@petra.dvoda.cz>
References: <45E2C289.30506@RedHat.com>
	<17891.53582.325117.716540@notabene.brown>
	<20070227093424.GE3954@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cory Olmo <colmo@TrustedCS.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HM0lq-0003Hr-P7
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 03:45:27 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HM0lr-0003If-JT
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 03:45:28 -0800
In-Reply-To: <20070227093424.GE3954@petra.dvoda.cz>
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


On Tue, Feb 27, 2007 at 10:34:24AM +0100, Karel Zak wrote:
> On Tue, Feb 27, 2007 at 05:35:58PM +1100, Neil Brown wrote:
> > On Monday February 26, SteveD@redhat.com wrote:
> > > commit 96a3ceb3d35bf5edcb9446aded8375d3b98b4f5b
> > > Author: Cory Olmo <colmo@TrustedCS.com>
> > > Date:   Sat Feb 24 16:20:40 2007 -0500
> > > 
> > >     This patch avoid the collision between commas in security contexts and the
> > >     delimiter betweeen mount options.
> > >     
> > >     Signed-off-by: Karel Zak <kzak@redhat.com>
> > >     Signed-off-by: Cory Olmo <colmo@TrustedCS.com>
> > > 
> > > diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> > > index b3d3696..f22747b 100644
> > > --- a/utils/mount/mount.c
> > > +++ b/utils/mount/mount.c
> > > @@ -285,18 +285,30 @@ static void parse_opts (const char *options, int *flags, char **extra_opts)
> > >  {
> > >  	if (options != NULL) {
> > >  		char *opts = xstrdup(options);
> > > -		char *opt;
> > > -		int len = strlen(opts) + 20;
> > > -
> > > +		char *opt, *p;
> > > +		int len = strlen(opts) + 256;
> > 
> > This is a worry.  If 20 isn't big enough, why do you thing 256 will
> 
>  The 20 was big enough for conversion from usernames to UIDs, but it's
>  not enough for selinux context names. I didn't found any definition
>  for maximal length of selinux context name, so we need to select any
>  range and assume that it's enough (or completely rewrite this part of
>  the mount command and allocate all dynamically).

 Well, it seems like non-invasive change to use realloc() for
 extra_opts string. I'll prepare a patch with this change in next
 weeks.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
