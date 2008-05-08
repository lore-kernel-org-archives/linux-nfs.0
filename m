From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH - nfs-utils] Make sure statd gets started when 'string options' are in use.
Date: Thu, 8 May 2008 12:48:18 +1000
Message-ID: <18466.27122.507819.788772@notabene.brown>
References: <18463.57567.260973.429439@notabene.brown>
	<F7A5F2B8-A400-425C-9D90-EAACC9E5F086@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58421 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845AbYEHCs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2008 22:48:26 -0400
In-Reply-To: message from Chuck Lever on Tuesday May 6
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday May 6, chuck.lever@oracle.com wrote:
> On May 6, 2008, at 12:38 AM, Neil Brown wrote:
> > The code for checking and starting statd was only in the binary- 
> > options
> > branch of the code.
> > This moves it into common code.
> > ---
> > utils/mount/mount.c    |   22 ++++++++++++++++++++--
> > utils/mount/nfsmount.c |   11 -----------
> > 2 files changed, 20 insertions(+), 13 deletions(-)
> >
> > diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> > index 5076468..0036caa 100644
> > --- a/utils/mount/mount.c
> > +++ b/utils/mount/mount.c
> > @@ -334,7 +334,8 @@ static void parse_opt(const char *opt, int  
> > *mask, char *extra_opts, int len)
> >  * standard options (indicated by MS_ bits), and output parameter
> >  * "@extra_opts" gets all the filesystem-specific options.
> >  */
> > -static void parse_opts(const char *options, int *flags, char  
> > **extra_opts)
> > +static void parse_opts(const char *options, int *flags, char  
> > **extra_opts,
> > +		       int *lock)
> > {
> > 	if (options != NULL) {
> > 		char *opts = xstrdup(options);
> > @@ -358,6 +359,10 @@ static void parse_opts(const char *options, int  
> > *flags, char **extra_opts)
> > 			/* end of option item or last item */
> > 			if (*p == '\0' || *(p + 1) == '\0') {
> > 				parse_opt(opt, flags, *extra_opts, len);
> > +				if (strcmp(opt, "lock") == 0)
> > +					*lock = 1;
> > +				if (strcmp(opt, "nolock") == 0)
> > +					*lock = 0;
> > 				opt = NULL;
> > 			}
> > 		}
> > @@ -421,6 +426,7 @@ int main(int argc, char *argv[])
> > 	char *spec, *mount_point, *fs_type = "nfs";
> > 	char *extra_opts = NULL, *mount_opts = NULL;
> > 	uid_t uid = getuid();
> > +	int lock = 1;
> >
> > 	progname = basename(argv[0]);
> >
> > @@ -531,7 +537,7 @@ int main(int argc, char *argv[])
> > 		goto out;
> > 	}
> >
> > -	parse_opts(mount_opts, &flags, &extra_opts);
> > +	parse_opts(mount_opts, &flags, &extra_opts, &lock);
> >
> > 	if (uid != 0) {
> > 		if (!(flags & (MS_USERS|MS_USER))) {
> > @@ -546,6 +552,18 @@ int main(int argc, char *argv[])
> > 		goto out;
> > 	}
> >
> > +	if (!fake && lock) {
> > +		if (!start_statd()) {
> > +			nfs_error(_("%s: rpc.statd is not running but is "
> > +				"required for remote locking.\n"
> > +				"   Either use '-o nolock' to keep "
> > +				"locks local, or start statd."),
> > +					progname);
> > +			mnt_err = EX_FAIL;
> > +			goto out;
> > +		}
> > +	}
> > +
> 
> You probably want to gate this based on NFS version (ie do the  
> checking only for NFSv2/v3 mounts, and not for NFSv4 mounts)

Yes, of course :-(
I remember think about that but must have forgotten when I actually
cut the patch.

> 
> There is already a function in stropts.c (called  
> set_mandatory_options) that might be a better place to put the special  
> option parsing, as you can use the nice po_* calls, and it already has  
> a switch for detecting which NFS version is being requested.

I cannot bring myself to put code in a function called
"set_mandatory_options" which does not, in fact, set any options,
whether mandatory or not.

> 
> Since the common part of this code (start_statd) is already in a  
> helper, I would leave the existing logic in nfsmount.c, and just add a  
> handful of lines in stropts.c:set_mandatory_options that worries about  
> "lock/nolock" for NFSv2/v3 mounts.

So how about the following?

Thanks for the feedback.

NeilBrown

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cdd610e..be77d17 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -694,6 +694,17 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	if (!set_mandatory_options(type, &saddr, options))
 		goto out;
 
+	if (!fake && strcmp(type, "nfs4") != 0 &&
+	    po_rightmost(options, "nolock", "lock") != PO_KEY1_RIGHTMOST)
+		if (!start_statd()) {
+			nfs_error(_("%s: rpc.statd is not running but is "
+				    "required for remote locking.\n"
+				    "   Either use '-o nolock' to keep "
+				    "locks local, or start statd."),
+				  progname);
+			goto out;
+		}
+
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)
 		retval = nfsmount_bg(spec, node, type, hostname, flags,
 					options, fake, child, extra_opts);
