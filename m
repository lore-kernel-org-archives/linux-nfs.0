From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: mountd randomly crash and panic the server
Date: Wed, 02 May 2007 11:03:17 +0200
Message-ID: <463853D5.1020106@oxeva.fr>
References: <461CFABE.9050301@barazer.net>	<46234130.5020502@oxeva.fr>	<17955.21572.383131.837268@notabene.brown>	<4623830D.7040108@oxeva.fr>	<17956.8604.672536.126674@notabene.brown>	<46367FBC.6000007@oxeva.fr>
	<17974.33522.70308.585198@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjAkf-00073H-DU
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 02:03:58 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjAkb-0007Eb-Jb
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 02:04:00 -0700
In-Reply-To: <17974.33522.70308.585198@notabene.brown>
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

On 05/01/2007 1:59:46 +0200, Neil Brown <neilb@suse.de> wrote:
> 
>>   related kernel panics, which are, I suppose, not linked to the NFS 
>> problem (I still mention it because unrelated but linked problems like 
>> this sometimes happens)
> 
> CFQ panics ?  In cfq_dispatch_insert by any chance?
> 
> This patch from Jens Axboe might be what you need.
> 

The problem is exactly related to this function : Is this bug related to 
the NFS subsystem, or am I lucky and it appears you work on the CFQ 
scheduler as well ? :) I can test this patch, but since this bug panic() 
the kernel, I can't afford to hang the file server very often.

For now I have changed the scheduler to deadline with the 
/sys/block/<device>/queue/scheduler file. Is this patch already sent to 
the upstream kernel sources ?

Thanks,

Gabriel

> NeilBrown
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 9e37971..f965be7 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -532,6 +532,11 @@ static void cfq_add_rq_rb(struct request *rq)
>  
>  	if (!cfq_cfqq_on_rr(cfqq))
>  		cfq_add_cfqq_rr(cfqd, cfqq);
> +
> +	/*
> +	 * check if this request is a better next-serve candidate
> +	 */
> +	cfqq->next_rq = cfq_choose_req(cfqd, cfqq->next_rq, rq);
>  }
>  
>  static inline void
> @@ -1639,12 +1644,6 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
>  		cfqq->meta_pending++;
>  
>  	/*
> -	 * check if this request is a better next-serve candidate)) {
> -	 */
> -	cfqq->next_rq = cfq_choose_req(cfqd, cfqq->next_rq, rq);
> -	BUG_ON(!cfqq->next_rq);
> -
> -	/*
>  	 * we never wait for an async request and we don't allow preemption
>  	 * of an async request. so just return early
>  	 */
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
