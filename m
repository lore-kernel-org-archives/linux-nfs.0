From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Thu, 1 Mar 2007 10:08:17 +1100
Message-ID: <17894.2913.850879.838771@notabene.brown>
References: <45E2C1FD.7000506@RedHat.com>
	<17891.52293.103984.465480@notabene.brown>
	<45E43C92.6090805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMXvO-0008Dh-M2
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 15:09:30 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HMXvP-0002rL-E9
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 15:09:32 -0800
In-Reply-To: message from Peter Staubach on Tuesday February 27
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

On Tuesday February 27, staubach@redhat.com wrote:
> Neil Brown wrote:
> > On Monday February 26, SteveD@redhat.com wrote:
> >   
> >> commit 0ffd74c990aca3761b79316d47e1b1778273681c
> >> Author: Steve Dickson <steved@redhat.com>
> >> Date:   Sat Feb 24 15:27:46 2007 -0500
> >>
> >>     Added support to specify the AUTH_NONE security flavor (i.e. -o sec=none)
> >>     
> >
> > If you specify "-o sec=none" then data.pseudoflavor will == AUTH_NONE,
> > but
> >
> >   
> 
> This support is being added so that the client can mount a file system
> which was exported with sec=none.

Ok, so the Changelog comment could be improved...

> 
> This loop is looking for AUTH_NONE in the list of authentication
> flavors that the server supports and was returned through the MOUNT
> protocol during mounting.
> 
> Basically, if the server file system is exported with AUTH_NONE, then
> it doesn't matter what flavor that the client chooses, the server will
> always map it to AUTH_NONE and all requests will be processed with the
> anonymous uid and gid.

I still don't understand (sorry if I am being dense).
Surely a server could export a filesystem as AUTH_NONE or AUTH_UNIX or
krbi.  And it could matter a lot what auth the client uses because if
it uses AUTH_NONE it would have access to many fewer files than
e.g. AUTH_UNIX.

And surely if I mount with "-o sec=krbi", and the server only supports
AUTH_NONE, then the mount should fail.  But with the patch as given, I
think it will succeed.  What am I missing?

What exactly is the situation where the current code does the wrong
thing, and the new code does the right thing?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
