From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] [nfs-utils: mountd] exports too verbose.
Date: Fri, 16 Mar 2007 09:22:26 -0400
Message-ID: <45FA9A12.1030602@RedHat.com>
References: <45F6CB05.6010604@RedHat.com>
	<17913.58996.50116.344398@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSCOK-0000bn-Ke
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 06:22:44 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSCOK-0001cg-F0
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 06:22:44 -0700
In-Reply-To: <17913.58996.50116.344398@notabene.brown>
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

Neil Brown wrote:
> On Tuesday March 13, SteveD@redhat.com wrote:
>> This patch is relative to the git tree at:
>> git://git.infradead.org/~steved/nfs-utils.git
>> which has been updated to the nfs-utils-1.0.12
>> release.
>>
>> Please consider...
> 
> How about this instead...
> nfs-utils imposes an ordering to some extent.  hostnames first, then 
> subnets, the wildcards, then netgroups.
> If the two names are in different places in that ordering, then there
> really is no need to report anything, as in you case.
> 
> OK?
> 
> NeilBrown
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 6cf24ce..ed7fe35 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -490,6 +490,7 @@ void nfsd_export(FILE *f)
>  	int i;
>  	char *dom, *path;
>  	nfs_export *exp, *found = NULL;
> +	int found_type = 0;
>  
>  
>  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
> @@ -516,9 +517,10 @@ void nfsd_export(FILE *f)
>  				continue;
>  			if (strcmp(path, exp->m_export.e_path))
>  				continue;
> -			if (!found)
> +			if (!found) {
>  				found = exp;
> -			else {
> +				found_type = i;
> +			} else if (found_type == i) {
>  				xlog(L_WARNING, "%s exported to both %s and %s in %s",
>  				     path, exp->m_client->m_hostname, found->m_client->m_hostname,
>  				     dom);
hmm... isn't there still a possibility that every time
the mis-orders exported is accessed, the a message will
be logged? So it might make sense to only log this
message once, right?

Also since this is a reordering problem, shouldn't the
logged message say its a re-ordering problem, so
people will know how to fix it? At this point, the
message is stating the obvious... which is really
not that helpful as to how to avoid the message... imho..

steved.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
