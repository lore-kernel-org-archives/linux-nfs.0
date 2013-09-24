Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753836Ab3IXTSD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 15:18:03 -0400
Message-ID: <5241E587.8040503@RedHat.com>
Date: Tue, 24 Sep 2013 15:18:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] exportfs: Fix the default authentication flavour setting
References: <1380049625-2875-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380049625-2875-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/09/13 15:07, Trond Myklebust wrote:
> Commit 11ba3b1e01b67b7d19f26fba94fabdb60878e809 (Add a default flavor
> to an export's e_secinfo list) breaks the ordering of security flavours
> in the secinfo list, by reordering 'sec=sys' to always be the first
> secinfo flavour if one fails to set a default 'sec' setting.
> 
> An export of the form:
> 
> /export -sync,no_subtree_check,mp \
>            192.168.1.0/24(sec=krb5p:krb5i:krb5,rw,sec=sys,ro)
> 
> ends up getting translated by exportfs into the following entry in
> /var/lib/nfs/etab:
> 
> /export	192.168.1.0/24(ro,sync,wdelay,hide,nocrossmnt,\
>                        secure,root_squash,no_all_squash,\
> 		       no_subtree_check,secure_locks,acl,\
> 		       mountpoint,anonuid=65534,anongid=65534,\
> 		       sec=sys,ro,root_squash,no_all_squash,\
> 		       sec=krb5p:krb5i:krb5,rw,root_squash,no_all_squash)
> 
> Note how the 'sec=sys' is now listed first...
> 
> The fix is to defer adding the default flavour until the call to
> secinfo_show, when we can see if it is even needed at all.
> With the patch, the above export is now correctly entered in
> /var/lib/nfs/etab as:
> 
> /export	192.168.1.0/24(ro,sync,wdelay,hide,nocrossmnt,\
> 			secure,root_squash,no_all_squash,\
> 			no_subtree_check,secure_locks,acl,\
> 			mountpoint,anonuid=65534,anongid=65534,\
> 			sec=krb5p:krb5i:krb5,rw,root_squash,no_all_squash,\
> 			sec=sys,ro,root_squash,no_all_squash)
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
Committed....

steved.

> ---
>  support/nfs/exports.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index dea040f..3e99de6 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -63,6 +63,7 @@ static int	parsesquash(char *list, int **idp, int *lenp, char **ep);
>  static int	parsenum(char **cpp);
>  static void	freesquash(void);
>  static void	syntaxerr(char *msg);
> +static struct flav_info *find_flavor(char *name);
>  
>  void
>  setexportent(char *fname, char *type)
> @@ -201,6 +202,8 @@ void secinfo_show(FILE *fp, struct exportent *ep)
>  	struct sec_entry *p1, *p2;
>  	int flags;
>  
> +	if (ep->e_secinfo[0].flav == NULL)
> +		secinfo_addflavor(find_flavor("sys"), ep);
>  	for (p1=ep->e_secinfo; p1->flav; p1=p2) {
>  
>  		fprintf(fp, ",sec=%s", p1->flav->flavour);
> @@ -643,8 +646,6 @@ bad_option:
>  			cp++;
>  	}
>  
> -	if (ep->e_secinfo[0].flav == NULL)
> -		secinfo_addflavor(find_flavor("sys"), ep);
>  	fix_pseudoflavor_flags(ep);
>  	ep->e_squids = squids;
>  	ep->e_sqgids = sqgids;
> 
