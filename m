From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/10] mount.nfs: Fix background mounts
Date: Mon, 06 Aug 2007 20:31:29 -0400
Message-ID: <46B7BD61.7060304@oracle.com>
References: <20070803172415.3357.91411.stgit@monet.1015granger.net>	<20070806223152.GA7917@uio.no>
	<18103.46593.586196.718154@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000306010903050902050105"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IID0P-0004h7-QP
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 17:33:02 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IID0R-0003VV-NP
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 17:33:05 -0700
In-Reply-To: <18103.46593.586196.718154@notabene.brown>
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
--------------000306010903050902050105
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Tuesday August 7, sgunderson@bigfoot.com wrote:
>> On Fri, Aug 03, 2007 at 01:24:15PM -0400, Chuck Lever wrote:
>>> The new mount.nfs helper does not support background mounts.  Add support
>>> for background mounts.
>> I've now pushed the current git (which includes these patches) into Debian,
>> which will hopefully give us some experience with "bg" again. It seems to
>> have fixed some bugs of the old bg implementation, but this one still
>> remains:
>>
>>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=144185
>>
>> Any chance mount.nfs could simply ignore HUPs?
>>
>> /* Steinar */
>> -- 
>> Homepage: http://www.sesse.net/
> 
> Something like this?  Anyone want to test it?
> 
> NeilBrown

I copied the "bg" logic straight from util-linux, then simplified it. 
Using daemon() instead of fork() seems like a nice clean-up anyway. 
(It's just me, but I like a blank between the first and second argument 
of daemon() -- that matches the coding style in the rest of that file).

Steinar, it's not clear to me from the Debian bug report whether this is 
really a mount bug or an init scripts bug.  I assume this is something 
that did not work correctly for the legacy util-linux mount command either?

> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index a232519..5769cd2 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -530,9 +530,7 @@ int main(int argc, char *argv[])
>  		 * Parent exits immediately with success.  Make
>  		 * sure not to free "mount_point"
>  		 */
> -		if (fork() > 0)
> -			exit(0);
> -
> +		daemon(0,0);
>  		mnt_err = try_mount(spec, mount_point, flags, fs_type,
>  					&extra_opts, mount_opts, fake,
>  					nomtab, BACKGROUND);

--------------000306010903050902050105
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


--------------000306010903050902050105
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000306010903050902050105
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000306010903050902050105--
