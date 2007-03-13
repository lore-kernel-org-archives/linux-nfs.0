From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Tue, 13 Mar 2007 16:49:16 +1100
Message-ID: <17910.15196.104675.695016@notabene.brown>
References: <45E2C1FD.7000506@RedHat.com>
	<17891.52293.103984.465480@notabene.brown>
	<45E43C92.6090805@redhat.com>
	<17894.2913.850879.838771@notabene.brown>
	<45E6FB0B.7000204@redhat.com>
	<17895.41362.382320.934994@notabene.brown>
	<45E8427A.3030806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQzsx-0001h8-Cy
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 22:49:23 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQzsy-00070n-Sz
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 22:49:25 -0700
In-Reply-To: message from Peter Staubach on Friday March 2
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

On Friday March 2, staubach@redhat.com wrote:
> Neil Brown wrote:
> > On Thursday March 1, staubach@redhat.com wrote:
> >   
> >> This was used to address RH bz187370.
> >>     
> >
> > Thanks for the link.  It provides good context.
> >
> > I would have thought the appropriate response would have been the
> > following patch, and a suggestion to use
> >   mount -o sec=none .....
> > to mount the filesystem.
> > Do you see a problem with that?
> 
> Yes, that's not sufficient.  The client should be able to automatically
> "do the right thing".  The systems administrator shouldn't have to
> specify the authentication flavor to match the server flavor.  That
> systems administrator should only have to specify when there are
> specific requirements for that client.

Ok..... so maybe we want "-o sec=" to accept a list of flavours, with
the default being "-o sec=sys:none".  Would that be suitable?
We would pick the first one in the server's list that is also in the
clients list.
I'm not sure allowing a list to be specified is really needed, so the
following patch just causes the default to be effectively
sec=sys:none.
Would that suit?

I just really don't like the idea of sending NFS requests with
AUTH_SYS when mountd has said that it only supports AUTH_NONE.

> 
> And a question, I thought that I looked, and it did not appear that
> the kernel supported AUTH_NONE on the client side.  Did I miss it?

Well....
fs/nfs/super.c:nfs_pseudoflavour_to_name certainly recognises RPC_AUTH_NULL.
and net/sunrpc/auth.c:auth_flavors has authnull_ops.
So I suspect the kernel supports it.  I admit I haven't tried.

NeilBrown

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index f21c81c..eaf70f5 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -902,7 +902,7 @@ nfsmount(const char *spec, const char *node, int *flags,
 #if NFS_MOUNT_VERSION >= 2
 	data.namlen	= NAME_MAX;
 #endif
-	data.pseudoflavor = AUTH_SYS;
+	data.pseudoflavor = -1; /* accept AUTH_SYS or AUTH_NONE */
 
 	bg = 0;
 	retry = 10000;		/* 10000 minutes ~ 1 week */
@@ -1090,6 +1090,14 @@ nfsmount(const char *spec, const char *node, int *flags,
 
 		flavor = mountres->auth_flavors.auth_flavors_val;
 		while (--i >= 0) {
+			/* If no flavour requests, use any simple
+			 * flavour that is offered.
+			 */
+			if (data.pseudoflavor == -1 &&
+			    (flavor[i] == AUTH_SYS ||
+			     flavor[i] == AUTH_NONE))
+				data.pseudoflavor = flavor[i];
+
 			if (flavor[i] == data.pseudoflavor)
 				yum = 1;
 #ifdef NFS_MOUNT_DEBUG

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
