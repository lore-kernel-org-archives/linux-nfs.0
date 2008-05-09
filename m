From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - nfs-utils] Make sure statd gets started when 'string options' are in use.
Date: Fri, 9 May 2008 10:39:06 +1000
Message-ID: <18467.40234.517764.643337@notabene.brown>
References: <18463.57567.260973.429439@notabene.brown>
	<F7A5F2B8-A400-425C-9D90-EAACC9E5F086@oracle.com>
	<18466.27122.507819.788772@notabene.brown>
	<7E3DAF69-8554-46C5-B585-AFE03DAD9D45@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:57763 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755376AbYEIAjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 20:39:15 -0400
In-Reply-To: message from Chuck Lever on Thursday May 8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday May 8, chuck.lever@oracle.com wrote:
> On May 7, 2008, at 10:48 PM, Neil Brown wrote:
> >
> > I cannot bring myself to put code in a function called
> > "set_mandatory_options" which does not, in fact, set any options,
> > whether mandatory or not.
> 
> /me makes the Scooby noise... (or is it the Tim Allen noise?)

Great impersonation!! (or is that an 'imdogonation' ??)

> 
> Huh?  set_mandatory_options sets up both "addr=" and "clientaddr=".   
> Both of these are required by the kernel, thus they are mandatory  
> options.  So I don't understand your objection.

Ah.. I see how I could be read differently from how I meant it.
What if I change it to:

 I cannot bring myself to put code which does not set any options into
 a function called "set_mandatory_options".

??

> 
> That function is the designated place to do specific option  
> processing, and even has a specific check for which type of file  
> system is being mounted.  Your fix would be simpler (it would add less  
> redundant logic) if it were added in set_mandatory_options().
> 
> It's easy enough to change the name of the function if you think that  
> would help make it more clear.

Good.  How about this?

Thanks,
NeilBrown

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cdd610e..2de77a8 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -218,14 +218,29 @@ static int fix_mounthost_option(struct mount_options *options)
 	return 0;
 }
 
+static int verify_lock_option(struct mount_options *options)
+{
+	if (po_rightmost(options, "nolock", "lock") != PO_KEY1_RIGHTMOST
+	    && !start_statd()) {
+		nfs_error(_("%s: rpc.statd is not running but is "
+			    "required for remote locking.\n"
+			    "   Either use '-o nolock' to keep "
+			    "locks local, or start statd."),
+			  progname);
+		return 0;
+	}
+	return 1;
+}
+
 /*
  * Set up mandatory mount options.
  *
  * Returns 1 if successful; otherwise zero.
  */
-static int set_mandatory_options(const char *type,
-				 struct sockaddr_in *saddr,
-				 struct mount_options *options)
+static int validate_options(const char *type,
+			    struct sockaddr_in *saddr,
+			    struct mount_options *options,
+			    int fake)
 {
 	if (!append_addr_option(saddr, options))
 		return 0;
@@ -236,6 +251,8 @@ static int set_mandatory_options(const char *type,
 	} else {
 		if (!fix_mounthost_option(options))
 			return 0;
+		if (!fake && verify_lock_option(options))
+			return 0;
 	}
 
 	return 1;
@@ -691,7 +708,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		goto fail;
 	}
 
-	if (!set_mandatory_options(type, &saddr, options))
+	if (!validate_options(type, &saddr, options, fake))
 		goto out;
 
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)
