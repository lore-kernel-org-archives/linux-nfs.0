From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils-1.1.0-rc1 - sm_unmon_1_svc should
	use	dnsname
Date: Thu, 3 May 2007 09:34:59 +1000
Message-ID: <17977.8227.860506.958457@notabene.brown>
References: <1176909165.8837.16.camel@wendyc-t.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjOM4-0004Zp-Th
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 16:35:29 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjOM6-0007Ez-24
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 16:35:31 -0700
In-Reply-To: message from Wendy Cheng on Wednesday April 18
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

On Wednesday April 18, wcheng@redhat.com wrote:
> The sm_unmon_1_svc() should have used dnsname.
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> 
> --- nfs-utils-1.1.0-rc1/utils/statd/monitor.c	2007-03-28 23:55:33.000000000 -0400
> +++ nfs-utils-t/utils/statd/monitor.c	2007-04-18 10:59:34.000000000 -0400
> @@ -357,7 +357,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
>  			ha_callout("del-client", mon_name, my_name, -1);
>  
>  			nlist_free(&rtnl, clnt);
> -			xunlink(SM_DIR, mon_name, 1);
> +			xunlink(SM_DIR, clnt->dns_name, 1);
>  
>  			return (&result);
>  		} else
> 

Thanks.  I've finally applied this with a few related fixes.

NeilBrown

--

Subject: [PATCH] statd - the files created are named for dns_name, so use that when unlinking.

Also free dns_name when freeing an 'nlist', so do the unlink before the free.
---
 utils/statd/monitor.c |    4 ++--
 utils/statd/notlist.c |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index c447a26..e40ff7d 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -380,8 +380,8 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
 
+			xunlink(SM_DIR, clnt->dns_name, 1);
 			nlist_free(&rtnl, clnt);
-			xunlink(SM_DIR, mon_name, 1);
 
 			return (&result);
 		} else
@@ -445,8 +445,8 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 			temp = NL_NEXT(clnt);
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
+			xunlink(SM_DIR, clnt->dns_name, 1);
 			nlist_free(&rtnl, clnt);
-			xunlink(SM_DIR, mon_name, 1);
 			++count;
 			clnt = temp;
 		} else
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index b74d9df..1698c26 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -211,6 +211,7 @@ nlist_free(notify_list **head, notify_list *entry)
 		free(NL_MY_NAME(entry));
 	if (NL_MON_NAME(entry))
 		free(NL_MON_NAME(entry));
+	free(entry->dns_name);
 	free(entry);
 }
 
-- 
1.5.1.2


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
