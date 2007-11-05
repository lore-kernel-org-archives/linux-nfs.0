From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH nfs-utils 2/3] Correctly probe mount v2
Date: Mon, 05 Nov 2007 13:01:05 -0500
Message-ID: <472F5A61.7090009@redhat.com>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>	<1193894817-20622-2-git-send-email-neilb@suse.de>	<1193894817-20622-3-git-send-email-neilb@suse.de>
	<472EF773.5020200@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ip6HM-0005K3-KX
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 10:02:28 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ip6HR-0007lH-UA
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 10:02:34 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lA5I2KC8008684
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 13:02:20 -0500
In-Reply-To: <472EF773.5020200@RedHat.com>
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

Steve Dickson wrote:
> Neil Brown wrote:
>   
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index 2b09457..38d0135 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -494,7 +494,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
>>  	for (; *probe_vers; probe_vers++) {
>>  		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
>>  		if ((res = probe_nfsport(nfs_server) != 0)) {
>> -			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
>> +			mnt_pmap->pm_vers = *probe_vers;
>>  			if ((res = probe_mntport(mnt_server)) != 0)
>>  				return 1;
>>  			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
>>     
>
> This patch does indeed fix mounts in the case where servers only support
> version 2 of the mount protocol. Meaning "mount server:/export /mnt/v2"
> now work when mountd only registers version 2 of the mnt protocol.
>
> But I happen to also notice that when setting the nfsvers
>     "mount -o vers=2 server:/export /mnt/v2"
>
> the mount fails, because the mount command assumes version 1 (of the mnt
> protocol) should be used and never tries any other versions. A similar
> assumption is made on the umount side as well.
>
> So I guess the question is, what correlation (if any) is there between
> the mount version and nfs version that is used? Do nfsvers=2 mounts
> have to use version 1 of the mnt protocol? What is the problem if
> v3 mounts use version 2 of the mnt protocol?
>
>   

MOUNT Version 2 is the same as MOUNT Version 1 plus the addition
of the Posix style PATHCONF operation.  Thus, NFS Version 2 can
use either MOUNT Version 1 or MOUNT Version 2 to get the original
file handle.

MOUNT Version 3 was designed to be used with NFS Version 3.  It
should not be used with earlier versions of the NFS protocols nor
should NFS Version 3 depend upon the file handles returned from
MOUNT Version 1 or MOUNT Version 2.

Most NFS server implementations _happen_ to use the same file
handles for NFS Version 2 and NFS Version 3, for ease of
implementation, but this is not a safe assumption to make on
behalf of a client.

    Thanx...

       ps

> My answers would be None, No and None to those questions, but maybe
> I'm missing something...
>
> Below is an RFC patch that removes these assumption:
>
>   diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 38d0135..c929986 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -481,8 +481,12 @@ int probe_bothports(clnt_addr_t *mnt_server, 
> clnt_addr_t *nfs_server)
>
>   	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
>   		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
> -	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
> -		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
> +	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers) {
> +		/* Does it matter which mount version is used
> +		 * when the nfs version is set ?
> +		 */
> +		mnt_pmap->pm_vers = 0;
> +	}
>   	if (nfs_pmap->pm_vers)
>   		goto version_fixed;
>
> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
> index 285273b..4209514 100644
> --- a/utils/mount/nfsumount.c
> +++ b/utils/mount/nfsumount.c
> @@ -195,12 +195,6 @@ static int do_nfs_umount23(const char *spec, char 
> *opts)
>   		pmap->pm_prog = atoi(p+10);
>   	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))
>   		pmap->pm_port = atoi(p+10);
> -	if (opts && hasmntopt(&mnt, "v2"))
> -		pmap->pm_vers = nfsvers_to_mnt(2);
> -	if (opts && hasmntopt(&mnt, "v3"))
> -		pmap->pm_vers = nfsvers_to_mnt(3);
> -	if (opts && (p = strstr(opts, "vers=")) && isdigit(*(p+5)))
> -		pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
>   	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
>   		pmap->pm_vers = atoi(p+10);
>   	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
>
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
