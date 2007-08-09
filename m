From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: inconsistencies in nfs(5)
Date: Thu, 09 Aug 2007 12:27:07 -0400
Message-ID: <46BB405B.5050206@oracle.com>
References: <46BB2DF2.1050501@oracle.com> <169a.46bb3b18.7157f@altium.nl>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090305010206070805070505"
Cc: nfs@lists.sourceforge.net
To: Dick Streefland <dick.streefland@altium.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJAsl-0006jO-I9
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 09:29:07 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJAso-0000YV-DS
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 09:29:11 -0700
In-Reply-To: <169a.46bb3b18.7157f@altium.nl>
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
--------------090305010206070805070505
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

rnews@tasking.nl wrote:
> Chuck Lever <chuck.lever@oracle.com> wrote:
> | +  The description for the "bg" option claims "After a mount operation 
> | is backgrounded, all subsequent mounts on the same NFS server will be 
> | backgrounded immediately, without first attempting the mount."  I don't 
> | think there's logic to do that in either the legacy mount command or in 
> | mount.nfs.  Should this text be removed from the man page?
> 
> I added that text in 1997, in a patch that was included in mount-2.7g.
> It referred to the following fragment in nfsmount.c:
> 
> +       /*
> +        * If the previous mount operation on the same host was
> +        * backgrounded, and the "bg" for this mount is also set,
> +        * give up immediately, to avoid the initial timeout.
> +        */
> +       if (bg && !running_bg &&
> +           prev_bg_host && strcmp(hostname, prev_bg_host) == 0) {
> +               if (retry > 0)
> +                       retval = EX_BG;
> +               return retval;
> +       }
> 
> This code got removed somewhere after util-linux-2.12p, but I don't
> know the details.

This is still in utils/mount/nfsmount.c.

I'm not sure how this can affect other mount commands running 
concurrently on the same client.  The man page implies that if one mount 
command has backgrounded against a server, subsequent mount commands 
against the same server will just go right into the background.  But 
prev_bg_host is unique in each instance of the mount command.

Can you help me understand what you intended?  Do you have a test case?

--------------090305010206070805070505
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------090305010206070805070505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090305010206070805070505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090305010206070805070505--
