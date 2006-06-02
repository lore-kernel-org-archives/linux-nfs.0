From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] expkey_parse doesn't handle type 3 exports (was
	Re: Problems with fh_fsid_type=3 exports (device minor id > 255))
Date: Fri, 2 Jun 2006 12:05:45 +1000
Message-ID: <17535.40185.244677.24906@cse.unsw.edu.au>
References: <1148669319.12795.44.camel@dyn9047022153>
	<1149115719.12795.49.camel@dyn9047022153>
	<1149117333.12795.53.camel@dyn9047022153>
	<17534.24605.250498.8288@cse.unsw.edu.au>
	<1149175424.12795.57.camel@dyn9047022153>
	<1149184319.12795.63.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Flz34-0005Sh-1B
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 19:06:02 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Flz31-0006b1-Jx
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 19:06:02 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: message from Frank Filz on Thursday June 1
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

On Thursday June 1, ffilzlnx@us.ibm.com wrote:
> 
> I tried the 1.0.8 version of rpc.mountd, and things almost worked, but
> the mount still failed. I looked at expkey_parse, and discovered it
> doesn't handle type 3 exports. The following patch fixes the problem:
> 
> Signed-Off-By: Frank Filz <ffilzlnx@us.ibm.com>
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -132,7 +132,7 @@ static int expkey_parse(struct cache_det
>  	if (*ep)
>  		goto out;
>  	dprintk("found fsidtype %d\n", fsidtype);
> -	if (fsidtype > 2)
> +	if (fsidtype > 3)
>  		goto out;
>  	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
>  		goto out;
> 

Thanks!
I'll make it 
	if (key_len(fsidtype)==0)
to reduce the chance of the same mistake happening again.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
