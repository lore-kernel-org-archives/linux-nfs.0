From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH 0 / 1] Move NFS mount code from util-linux
 to	nfs-utils - take2
Date: Thu, 15 Jun 2006 23:24:26 -0400
Message-ID: <4492246A.9000206@redhat.com>
References: <448DF279.8090005@redhat.com> <44918BDD.2C84.006B.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fr4ti-0007GY-RM
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:21:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fr4th-0008IV-MC
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:21:27 -0700
To: Chakravarthi P <pchakravarthi@novell.com>
In-Reply-To: <44918BDD.2C84.006B.0@novell.com>
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

Chakravarthi P wrote:
> in mount.c :
> 
> +void mount_usage()
> +{
> +	printf("usage: %s remotetarget dir [-rvVwfnh] [-t version] [-o
> nfsoptions]\n", progname);
> +	printf("options:\n\t-r\t\tMount file system readonly\n");
> +	printf("\t-v\t\tVerbose\n");
> +	printf("\t-V\t\tPrint version\n");
> +	printf("\t-w\t\tMount file system read-write\n");
> 
> 1. isn't it generally a good practice to have usage message over stderr
> ?
> so the user doesn't miss it. even if he chances to redirect the output
> ...
> just a suggestion.
> 

yes, good idea.

> +			break;
> +		case 't':
> +			nfs_mount_vers = (strncmp(optarg, "nfs4", 4)) ?
> 0 : 4;
> +			break;
> 
> 2.  i dont think a -t option makes sense for mount.nfs  
>      mount.nfs itself says it is a nfs file system
>      you can pick up the version from -o nfsvers=4  to cater to nfs
> version
>      -t is by legacy meant for specifying the filesystem type.
>       
>       i also don't see why bind and other options need to be there for
> mount.nfs
> 

The mount.nfs, though a subcommand for mount, is meant to be used even 
as a standalone binary with the limited functionality. -t option is 
there because theres just one binary for the different NFS versions, and 
-t is just used as a way to give the filesystem type, just like for 
mount there are nfs and nfs4 options for -t.


> +
> +int add_mtab(char *fsname, char *mount_point, char *fstype, int flags,
> char *opts, int freq, int passno)
> +{
> 
> 3. felt that there can be just be one function called mtab_update that
> can be kept in 
>     the common utility source files you had so that both umount and
> mount code can use it.

Yes, I will reorganize this.

> in nfs4mount.c
> +#if defined(VAR_LOCK_DIR)
> +#define DEFAULT_DIR VAR_LOCK_DIR
> +#else
> +#define DEFAULT_DIR "/var/lock/subsys"
> +#endif
> +
> +extern int verbose;
> +
> +char *IDMAPLCK = DEFAULT_DIR "/rpcidmapd";
> +#define idmapd_check() do { \
> +	if (access(IDMAPLCK, F_OK)) { \
> +		printf(_("Warning: rpc.idmapd appears not to be
> running.\n" \
> +			"         All uids will be mapped to the nobody
> uid.\n")); \
> +	} \
> +} while(0);
> +
> +char *GSSDLCK = DEFAULT_DIR "/rpcgssd";
> +#define gssd_check() do { \
> +		if (access(GSSDLCK, F_OK)) { \
> +			printf(_("Warning: rpc.gssd appears not to be
> running.\n")); \
> +		} \
> +} while(0); 
> 
> 
> 4. very nice thing to do ... warn the user if idmapd and gssd are not
> running.
>     But then idmapd on suse doesn't seem to be writing into
> /var/lock/subsys ... 
>     Is /var/lock/subsys/  the standard way for daemons to show their
> existence. ?
>     or is creation of  /var/run/<daemon_name>  a standard ?
>     then idmapd scripts might need some change .. or else ..
>     code needs some modification here to be able to work fine in all
> distros ...

I suppose /var/lock/subsys/ is the standard directory. I inherited the 
DEFAULT_DIR, that was being used in the util-linux mount.

> in nfsumount.c :
> 
> +	spec = argv[1];
> +
> +	argv += 1;
> +	argc -= 1;
> +
> +	while ((c = getopt_long (argc, argv, "fvnrlh",
> +				umount_longopts, NULL)) != -1) {
> 
>  it'll be nice if you include -a option and have all nfs or nfs4 mounts
> umounted on calling
>  umount.nfs -a 
>  this is should be easy enough with an appropriate mtab utility
> function.
> 

Yes, nice idea.


Best,
AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
