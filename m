From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/3] NLM lock failover
Date: Mon, 31 Jul 2006 22:13:55 -0400
Message-ID: <1154398435.3378.29.camel@localhost.localdomain>
References: <1154397991.3378.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7jaS-0007e6-8Q
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 19:02:24 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7jaS-0006PD-EM
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 19:02:24 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k7122LlO001139
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 22:02:21 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <1154397991.3378.22.camel@localhost.localdomain>
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

Sorry, please discard this .. I added the wrong subject line.. Will
resend... Wendy

On Mon, 2006-07-31 at 22:06 -0400, Wendy Cheng wrote:
> This patch enables per ip NLM lock grace period. The implementation is
> based on a global single linked list nlm_servs that contains entries of
> per server ip info. It is expected this would not be a frequent event.
> The nlm_servs list should be short and the entries expire within a
> maximum of 50 seconds. The grace period setting follows the existing NLM
> grace period handling logic and is triggered via echoing the ipv4 dot
> address into /proc/fs/nfsd/nlm_set_ip_grace file.
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> Signed-off-by: Lon Hohberger <lhh@redhat.com>
> 
> fs/lockd/svc.c              |    8 +-
> fs/lockd/svc4proc.c         |   41 ++++++++++---
> fs/lockd/svcproc.c          |   43 +++++++++++---
> fs/lockd/svcsubs.c          |  133 +++++++++++++++++++++++++++++++++++++
> ++++++ 
> fs/nfsd/nfsctl.c            |   36 +++++++++++
> include/linux/lockd/bind.h  |    3
> include/linux/lockd/lockd.h |   15 ++++
> 7 files changed, 261 insertions(+), 18 deletions(-)
> 
> 
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
