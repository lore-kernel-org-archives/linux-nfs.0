From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 006 of 8] knfsd: nfsd4: fslocations data structures
Date: Thu, 28 Sep 2006 23:45:40 -0700
Message-ID: <20060928234540.fd74f1e1.akpm@osdl.org>
References: <20060929130518.23919.patches@notabene>
	<1060929030913.24108@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GTC7y-0000CT-7e
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:45:42 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GTC7y-0004zf-U0
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:45:43 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060929030913.24108@suse.de>
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

On Fri, 29 Sep 2006 13:09:13 +1000
NeilBrown <neilb@suse.de> wrote:

> 
> From: Manoj Naik <manoj@almaden.ibm.com>
> 
> Define FS locations structures, some functions to manipulate them, and add
> code to parse FS locations in downcall and add to the exports structure.
> 
> ...
>  
> +#ifdef CONFIG_NFSD_V4
> +
> +static int
> +fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
> +{
> +	int len;
> +	int migrated, i, err;
> +
> +	len = qword_get(mesg, buf, PAGE_SIZE);
> +	if (len != 5 || memcmp(buf, "fsloc", 5))
> +		return 0;
> +
> +	/* listsize */
> +	err = get_int(mesg, &fsloc->locations_count);
> +	if (err)
> +		return err;
> +	if (fsloc->locations_count < 0)

this is unsigned.

> +		return -EINVAL;
> +	if (fsloc->locations_count == 0)
> +		return 0;
> +
> +	fsloc->locations = kzalloc(fsloc->locations_count
> +			* sizeof(struct nfsd4_fs_location), GFP_KERNEL);

This is subject to multiplication overflow.  If it's a privileged operation
and isn't dependent on stuff coming in over the wire then ok..


> +	if (!fsloc->locations)
> +		return -ENOMEM;
> +	for (i=0; i < fsloc->locations_count; i++) {
> +		/* colon separated host list */
> +		err = -EINVAL;
> +		len = qword_get(mesg, buf, PAGE_SIZE);
> +		if (len <= 0)
> +			goto out_free_all;
> +		err = -ENOMEM;
> +		fsloc->locations[i].hosts = kstrdup(buf, GFP_KERNEL);
> +		if (!fsloc->locations[i].hosts)
> +			goto out_free_all;
> +		err = -EINVAL;
> +		/* slash separated path component list */
> +		len = qword_get(mesg, buf, PAGE_SIZE);
> +		if (len <= 0)
> +			goto out_free_all;
> +		err = -ENOMEM;
> +		fsloc->locations[i].path = kstrdup(buf, GFP_KERNEL);
> +		if (!fsloc->locations[i].path)
> +			goto out_free_all;
> +	}
> +	/* migrated */
> +	err = get_int(mesg, &migrated);
> +	if (err)
> +		goto out_free_all;
> +	err = -EINVAL;
> +	if (migrated < 0 || migrated > 1)
> +		goto out_free_all;
> +	fsloc->migrated = migrated;
> +	return 0;
> +out_free_all:
> +	nfsd4_fslocs_free(fsloc);

This call to nfsd4_fslocs_free() can end up kfreeing members of
fsloc->locations[] which haven't been initialised here.  Are we sure the
caller set them all to zero?

> +	return err;
> +}
> +
> +#else /* CONFIG_NFSD_V4 */
> +static int fsloc_parse(char **, char *, struct svc_export *) { return 0; }

static inline

This has a different prototype from the other version of fsloc_parse()

This ain't C++ - function arguments need identifiers as well as types.

Someone needs to read Documentation/SubmitChecklist..



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
