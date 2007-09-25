From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: initialize default port in kernel mount
	client
Date: Tue, 25 Sep 2007 11:58:21 -0400
Message-ID: <46F9301D.5060107@oracle.com>
References: <Pine.LNX.4.64.0709241731560.32008@jlentini-linux.nane.netapp.com>
	<46F83B09.2090202@oracle.com>
	<Pine.LNX.4.64.0709241942430.32008@jlentini-linux.nane.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020607060603060007040501"
Cc: nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaDwi-00089X-3h
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:11:40 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaDwj-0001DZ-NA
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:11:45 -0700
In-Reply-To: <Pine.LNX.4.64.0709241942430.32008@jlentini-linux.nane.netapp.com>
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
--------------020607060603060007040501
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

James Lentini wrote:
> 
> On Mon, 24 Sep 2007, Chuck Lever wrote:
> 
>> Hi James-
>>
>> James Lentini wrote:
>>> If no mount server port number is specified, this change to the kernel mount
>>> client
>>>
>>> http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=commitdiff;h=209ce98
>>> 06996537eceaf07d95def0e9300316c84
>>>
>>> inadvertently allows the NFS server's port number to be the used as the
>>> mount server's port number. If the user specifies an NFS server port (-o
>>> port=x), the mount will fail.
>>>
>>> The fix below sets the mount server's port to 0 if no mount server port is
>>> specified by the user.
>>>
>>> Signed-off-by: James Lentini <jlentini@netapp.com>
>>> --
>>>
>>>  super.c |    2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>> Index: nfs-2.6/fs/nfs/super.c
>>> ===================================================================
>>> --- nfs-2.6/fs/nfs/super.c
>>> +++ nfs-2.6/fs/nfs/super.c
>>> @@ -1006,6 +1006,8 @@ static int nfs_try_mount(struct nfs_pars
>>>  		sin = args->nfs_server.address;
>>>  	if (args->mount_server.port != 0)
>>>  		sin.sin_port = htons(args->mount_server.port);
>>> +	else
>>> +		sin.sin_port = htons(0);
>> Why not just set sin.sin_port = args->mount_server.port unconditionally?
> 
> Good observation. Something like this perhaps?
> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
> Index: nfs-2.6/fs/nfs/super.c
> ===================================================================
> --- nfs-2.6/fs/nfs/super.c
> +++ nfs-2.6/fs/nfs/super.c
> @@ -1004,8 +1004,10 @@ static int nfs_try_mount(struct nfs_pars
>  		sin = args->mount_server.address;
>  	else
>  		sin = args->nfs_server.address;
> -	if (args->mount_server.port != 0)
> -		sin.sin_port = htons(args->mount_server.port);
> +	/* 
> + 	 * autobind will be used if mount_server.port == 0
> + 	 */
> +	sin.sin_port = htons(args->mount_server.port);
>  
>  	/*
>  	 * Now ask the mount server to map our export path

That's the idea, but I don't think the comment is needed.

--------------020607060603060007040501
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


--------------020607060603060007040501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------020607060603060007040501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020607060603060007040501--
