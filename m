From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/5] mount.nfs: Fix one more double-wide character
	nit
Date: Fri, 10 Aug 2007 11:19:18 +1000
Message-ID: <18107.48406.21134.143337@notabene.brown>
References: <20070809213651.16767.2602.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJJA0-00052I-PJ
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:19:28 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJJA4-0000Ma-L6
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 18:19:33 -0700
In-Reply-To: message from Chuck Lever on Thursday August 9
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


It bothers me that you still seem to think the _() stuff is closely
connected with double/wide characters.   That is not what it is really
about.
There are quite possible no wide characters involved at all (depending
on the local language).

The question is:  Does this string need to be translated.
In that case of the strings "UDP" and "TCP", I suspect the answer is
"no".  However as I don't speak any other language, maybe I am wrong.

I'll happily accept a patch which simply changes "udp" to "UDP" as I
agree that is a correct change to make.
And I will also accept a patch that changes "udp" to _("UDP") if the
subject says "Allow protocol names to be translated" or something else
that mentions translation or localisation or different languages.

But - despite the fact that it probably seems like I'm being
unnecessarily picky - I don't want to accept this patch with this
subject.

Sorry :-)

NeilBrown


On Thursday August 9, chuck.lever@oracle.com wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/network.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 5a56c23..eb59c1f 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -388,7 +388,7 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>  						inet_ntoa(saddr->sin_addr),
>  						prog, *p_vers,
>  						*p_prot == IPPROTO_UDP ?
> -							"udp" : "tcp",
> +							_("UDP") : _("TCP"),
>  						p_port);
>                                  }
>  				if (clnt_ping(saddr, prog, *p_vers, *p_prot, NULL))

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
