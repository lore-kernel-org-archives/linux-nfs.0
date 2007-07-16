From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 04/17] mount.nfs: /bin/mount already handles
	--bind & friends
Date: Mon, 16 Jul 2007 13:44:29 +1000
Message-ID: <18074.59805.866117.453406@notabene.brown>
References: <20070716031509.11209.35069.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHVi-0004qg-5Q
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:44:34 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHVk-0007PX-7m
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:44:38 -0700
In-Reply-To: message from Chuck Lever on Sunday July 15
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

On Sunday July 15, chuck.lever@oracle.com wrote:
> Clean-up: remove logic to handle --bind and other such options from
> mount.nfs[4].
> 
> These options are already handled in /bin/mount, and the logic for handling
> them in the NFS helper is currently disabled.  Other helpers such as
> mount.ocfs2 appear not to support --bind (ie. they rely on /bin/mount to
> do it).

Fair enough - I don't suppose the protocol for how /bin/mount talks to
/sbin/mount.$fstype is documented anywhere???  I guess just in the
code :-(

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/mount.c           |   45 +++++------------------------------------
>  utils/mount/mount_constants.h |    6 +++++
>  2 files changed, 11 insertions(+), 40 deletions(-)
> 
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index 337d7cc..c05f907 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -75,11 +67,6 @@ struct opt_map {
>    int  mask;                    /* flag mask value */
>  };
>  
> -/* Custom mount options for our own purposes.  */
> -#define MS_DUMMY	0x00000000
> -#define MS_USERS	0x40000000
> -#define MS_USER		0x80000000
> -
>  static const struct opt_map opt_map[] = {
>    { "defaults", 0, 0, 0         },      /* default options */
>    { "ro",       1, 0, MS_RDONLY },      /* read-only */
> diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
> index 19a7bf5..3e40841 100644
> --- a/utils/mount/mount_constants.h
> +++ b/utils/mount/mount_constants.h
> @@ -39,6 +39,12 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
>  #ifndef MS_VERBOSE
>  #define MS_VERBOSE	0x8000	/* 32768 */
>  #endif
> +
> +/* Custom mount options for our own purposes.  */
> +#define MS_DUMMY	0x00000000
> +#define MS_USERS	0x40000000
> +#define MS_USER		0x80000000
> +
>  /*
>   * Magic mount flag number. Had to be or-ed to the flag values.
>   */

Hmmm.  That wasn't mentioned in the change-log, and I don't find it
convincing.
These flags are for internal use in mount.c so it makes lots of sense
to define them in mount.c so that the definitions never leak.
Did you have a concrete reason for moving them?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
