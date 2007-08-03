From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/10] mount.nfs: Shorter timeout for TCP connects
Date: Sat, 4 Aug 2007 08:20:44 +1000
Message-ID: <18099.43580.95942.585732@notabene.brown>
References: <20070803172349.3357.55907.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH5Vx-0000I3-Vl
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 15:20:58 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH5W0-0002ZE-6z
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 15:21:02 -0700
In-Reply-To: message from Chuck Lever on Friday August 3
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

On Friday August 3, chuck.lever@oracle.com wrote:
> The standard TCP connect timeout on Linux is 75 seconds, which can be
> too long in some cases.  The timeout itself can be altered on a system-wide
> basis, but we'd like mount to have it's own connect timeout that's tunable,
> and defaults to a shorter value.

75?  "man 7 tcp" suggest about 180, and a simple telnet test confirmed this.
The man page also suggests that this is due to 5 SYN packets being
sent, but I count 6 and intervals of 

 3, 6, 12, 24, 48, then 96 seconds until it gives up

This makes a total of 189.
You can change The number of SYN retries with the TCP_SYNCNT socket
option, but it is probably just as easy to use async connect and
select as you do.
The sensible timeouts would seem to be (just more than)
 3, 9, 21, 45, 93
seconds.  You have chosen 10, 20, 30

Any reason for that?  I'm having trouble justifying why the portmap,
the mountd and the 'ping' calls should have different timeouts.
I would probably go for 12 seconds each.  This allows 2 SYN requests,
and 3 seconds for a response to get back.  If that is too short, then
maybe 25 seconds.

Choosing timeouts is a very imprecise science, but I'd like to have at
least some understanding of what we pick the numbers we do.

What do you think?

Thanks,
NeilBrown


> 
> The get_socket() function is a utility function that does TCP connects for
> getport, clnt_ping, and other functions.  Add logic there to use a
> non-blocking connect() and select() in order to time out a connect
> operation that's taking too long.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/network.c |   64 +++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 59 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 220bbce..89cb976 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -52,6 +52,10 @@
>  #define NFS_PORT 2049
>  #endif
>  
> +#define PMAP_TIMEOUT	(10)
> +#define CONNECT_TIMEOUT	(20)
> +#define MOUNT_TIMEOUT	(30)
> +

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
