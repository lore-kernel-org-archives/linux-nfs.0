From: James Bardin <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Thu, 25 Jan 2007 14:43:11 -0500
Message-ID: <45B9084F.7090307@bu.edu>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>	
	<45B73D93.1020508@RedHat.com> <45B7C85C.80105@bu.edu>	
	<20070124233908.GS6587@fieldses.org>
	<a3b675320701241614p360a596fjb92723eb5ce6dfd9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAAVB-0003gY-EP
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:43:17 -0800
Received: from an-out-0708.google.com ([209.85.132.247])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAAVC-00040T-08
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:43:19 -0800
Received: by an-out-0708.google.com with SMTP id d40so652471and
	for <nfs@lists.sourceforge.net>; Thu, 25 Jan 2007 11:43:13 -0800 (PST)
In-Reply-To: <a3b675320701241614p360a596fjb92723eb5ce6dfd9@mail.gmail.com>
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

I'm almost there!
Between the nfs-utils patch, and the noacl option, I have my 32bit 
systems working. (thanks Steve)

On x86_64, I'm having kerberos problems (exact same config):

rpc.gssd[4871]: handling krb5 upcall
rpc.gssd[4871]: getting credentials for client with uid xxxx for server 
yyyy.bu.edu
rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' being considered
rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' matches name check and has 
mtime of 1169750861
rpc.gssd[4871]: using FILE:/tmp/krb5cc_xxxx_bSULEy as credentials cache 
for client with uid xxxx for server yyyy.bu.edu
rpc.gssd[4871]: creating context using euid xxxx (save_uid 0)
rpc.gssd[4871]: creating tcp client for server yyyy.bu.edu
rpc.gssd[4871]: WARNING: can't create rpc_clnt for server engna1.bu.edu 
for user with uid xxxx: RPC: Success 
rpc.gssd[4871]: WARNING: Failed to create krb5 context for user with uid 
xxxx for server yyyy.bu.edu
rpc.gssd[4871]: doing error downcall


-jim

>> Try using the -o noacl mount option...
>>
>> steved.
>>
>
> Steved,
> Ok, this seems to be it. ( I'll try out some other configuration/64bit 
> tomorrow)
> Could you give me a brief summary on why this is happening, and only
> on this kernel? Mostly, should I always be using noacl when the netapp
> is handling file access?
>
> thanks
> -jim
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
