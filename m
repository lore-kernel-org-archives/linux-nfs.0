From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH nfs-utils 1/3] probe_port should not try
 other	versions in a version was explicitly given.
Date: Thu, 01 Nov 2007 12:29:37 -0400
Message-ID: <4729FEF1.2070903@oracle.com>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050107090309060007060402"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IncwT-0005lP-Ub
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 09:30:50 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IncwX-0000n3-BY
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 09:30:55 -0700
In-Reply-To: <1193894817-20622-2-git-send-email-neilb@suse.de>
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

This is a multi-part message in MIME format.
--------------050107090309060007060402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> Currently if probe port is asked to probe for a specific version, and
> that version is not supported, it will probe other versions too.
> This means that if mountd is run with "--no-nfs-version 3",
> It will first probe for NFS version 3, which will succeed (assuming the
> kernel supported NFSv3), then it will check the matching mountd version (3)
> and probe_port on discovering that isn't supported will try other versions,
> find "1" is supported will succeed.
> 
> This leaves us using mount version 1 for an NFSv3 mount, which doesn't work
> and leads to a SIGSEGV
> 
> There is no case where trying other versions is needed the request one is
> not supported, so simply remove that code.

I agree with that understanding:  if the caller is asking for a specific 
version of the protocol in question, we aren't looking for a wildcard.

Time to add another case to our list of regression tests.

I wonder if the same misbehavior occurs when probing for transport 
protocols?

> Signed-off-by: Neil Brown <neilb@suse.de>
> ---
>  utils/mount/network.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 63d5f5a..2b09457 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -417,10 +417,6 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>  				continue;
>  			p_prot = protos;
>  		}
> -		if (vers == pmap->pm_vers) {
> -			p_vers = versions;
> -			vers = 0;
> -		}
>  		if (vers || !*++p_vers)
>  			break;
>  	}

--------------050107090309060007060402
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------050107090309060007060402
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------050107090309060007060402
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050107090309060007060402--
