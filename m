From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/4 Revised] NLM failover - nlm_set_igrace
Date: Tue, 26 Sep 2006 10:46:14 +1000
Message-ID: <17688.30806.252332.646157@cse.unsw.edu.au>
References: <4508DF1A.4090907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GS15h-00013n-HN
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:46:29 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GS15h-0002Wp-Ld
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:46:30 -0700
To: wcheng@redhat.com
In-Reply-To: message from Wendy Cheng on Thursday September 14
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

On Thursday September 14, wcheng@redhat.com wrote:
> This change enables per NFS-export entry lockd grace period. The 
> implementation is based on a double linked list fo_fsid_list that 
> contains entries of fsid info. It is expected this would not be a 
> frequent event. The fo_fsid_list is short and the entries expire within 
> a maximum of 50 seconds.  The grace period setting follows the existing 
> NLM grace period handling logic and is triggered via echoing the NFS 
> export filesystem id into nfsd procfs entry as:
> 
> shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace

What is the 'i' for?
How about  /proc/fs/nfsd/nlm_set_grace_for_fsid ??

> --- linux-1/include/linux/lockd/lockd.h	2006-09-03 21:51:41.000000000 -0400
> +++ linux-2/include/linux/lockd/lockd.h	2006-09-13 22:48:00.000000000 -0400
> @@ -107,6 +107,17 @@ struct nlm_file {
>  	int		       	f_hash;		/* hash of f_handle */
>  };
>  
> +#define NLM_FO_MAX_FSID_GP	127

Why do you need this limit?

> + *
> + * Also, please don't ask why using opencoded list manipulation, 
> + * instead of <linux/list.h>, unless you can point to me where
> + * in that file have existing macro and/or functions that can do
> + * single linked list. 

I don't think this comment is appropriate any more.  You are using
list.h lists, not open coding them.


> +	/* check to see whether this_fsid is in fo_fsid_list list */
> +	list_for_each_safe(p, tlist, &fo_fsid_list) {
> +		e_this = list_entry(p, struct fo_fsid, g_list);
> +		if (time_before(e_this->g_expire, jiffies)) {
> +			printk("lockd: fsid=%d grace period expires\n",
> +				e_this->g_fsid);
> +			list_del(p);
> +			fo_fsid_cnt--;
> +			kfree(e_this);
> +		} else if (e_this->g_fsid == this_fsid) {
> +			if (!e_this->g_flag) {
> +				e_this->g_flag = 1;
> +				printk("lockd: fsid=%d in grace period\n",
> +					e_this->g_fsid);
> +			}
> +			rc = 1;

I assume this 'g_flag' was just for debugging.  Can it be take out
now?
Also, I though you should break out of the loop once you set rc = 1.

>   * Obtain client and file from arguments
>   */
> @@ -89,7 +102,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
>  	resp->cookie = argp->cookie;
>  
>  	/* Don't accept test requests during grace period */
> -	if (nlmsvc_grace_period) {
> +	if ((nlmsvc_grace_period) || (nlm4svc_fo_grace_period(argp))) {
>  		resp->status = nlm_lck_denied_grace_period;
>  		return rpc_success;
>  	}

I think this (and the rest) would look cleaner if you put the
'nlmsvc_grace_period' test into the nlm4svc_fo_grace_period function.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
