Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753497AbdBPKXT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Feb 2017 05:23:19 -0500
Subject: Re: [PATCH] nfs-server-generator: handle 'noauto' mounts correctly.
To: NeilBrown <neilb@suse.com>
References: <87poitv3p4.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <6bd4a1b9-1094-6b85-ce84-2f80880fa9cd@RedHat.com>
Date: Thu, 16 Feb 2017 05:23:18 -0500
MIME-Version: 1.0
In-Reply-To: <87poitv3p4.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2017 09:03 PM, NeilBrown wrote:
> When this code was written, the systemd documentation stated
> that "RequiresMountsFor" ignored mountpoints marked as "noauto".
> Unfortunately this is incorrect.  Consquently a filesystem marked
> as noauto that is also NFS exported will currently be mounted when
> the NFS server is started. This is not what people expect.
>
> So add a check for the noauto flag.  If any ancestor of a given
> export point has the noauto flag, no RequiresMountsFor will be
> generated for that point.
>
> Also skip RequiresMountsFor for exports marked 'mountpoint', as their
> absence is, theoretically, already handled by mountd.
>
> URL: https://github.com/systemd/systemd/issues/5249
> Signed-off-by: NeilBrown <neilb@suse.com>
Committed...

steved.
> ---
>  systemd/nfs-server-generator.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>
> diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
> index cc99969e9922..4aa65094ca07 100644
> --- a/systemd/nfs-server-generator.c
> +++ b/systemd/nfs-server-generator.c
> @@ -84,6 +84,28 @@ static void systemd_escape(FILE *f, char *path)
>  	}
>  }
>  
> +static int has_noauto_flag(char *path)
> +{
> +	FILE		*fstab;
> +	struct mntent	*mnt;
> +
> +	fstab = setmntent("/etc/fstab", "r");
> +	if (!fstab)
> +		return 0;
> +
> +	while ((mnt = getmntent(fstab)) != NULL) {
> +		int l = strlen(mnt->mnt_dir);
> +		if (strncmp(mnt->mnt_dir, path, l) != 0)
> +			continue;
> +		if (path[l] && path[l] != '/')
> +			continue;
> +		if (hasmntopt(mnt, "noauto"))
> +			break;
> +	}
> +	fclose(fstab);
> +	return mnt != NULL;
> +}
> +
>  int main(int argc, char *argv[])
>  {
>  	char		*path;
> @@ -124,6 +146,10 @@ int main(int argc, char *argv[])
>  		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
>  			if (!is_unique(&list, exp->m_export.e_path))
>  				continue;
> +			if (exp->m_export.e_mountpoint)
> +				continue;
> +			if (has_noauto_flag(exp->m_export.e_path))
> +				continue;
>  			if (strchr(exp->m_export.e_path, ' '))
>  				fprintf(f, "RequiresMountsFor=\"%s\"\n",
>  					exp->m_export.e_path);

