From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: Status of NFS over IPv6
Date: Mon, 02 Jul 2007 11:36:12 +0200
Message-ID: <4688C70C.2050801@ext.bull.net>
References: <20070629123747.GA1034@uio.no> <46858153.8060109@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFSv4 ML <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@fieldses.org>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5ILC-0007Qs-O0
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 02:37:06 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5ILD-0003Fg-35
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 02:37:09 -0700
In-Reply-To: <46858153.8060109@oracle.com>
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

Chuck Lever wrote:

>>
>> I'd very much like to be able to sew all of this together at some point,
>> but it's very hard to get a decent overview of it all. Does anyone 
>> have a
>> "current status" or "plans for the near feature" summary?
>
>
> I have some patches that add IPv6 support in the RPC client.  The 
> server is more complicated (how to deal with address-based export 
> rules, and so on).  There hasn't been much progress on the server 
> side, but I think Bull is still working on that.

The latest server patches are on our web page. I have upgraded it.
http://nfsv4.bullopensource.org/patches/ipv6-server/IPv6_patchset.php

It includes missing parts of code. I have started from a 2.6.21 kernel + 
Chuck patchset.
I have send them to Bruce few weeks ago. Bruce did you received the URL 
of new patches ?

> Steve Dickson has added Bull's rpcbind (replacement for portmap) to 
> Fedora 7, but there is some disagreement about whether to use a 
> complete replacement, like rpcbind, or whether to add the needed 
> support to the existing portmap code, in general.
>
> Bull has announced a test plan for user-space RPC libraries, although 
> I haven't had a moment to look through it.  Bull should be providing 
> testing resources once we have all of this integrated.
>
A student is developing a RPC/TI-RPC test suite. TI-RPC and RPCbind 
adoption by the community has been discussed on the mailing list few 
weeks ago.

> While there is some interest in IPv6 among some of Linux's corporate 
> sponsors, there really isn't an overwhelming "killer" requirement for 
> IPv6, so there isn't much motivation to get all this completed.  I 
> have to admit I'm pretty burned out on all this because of how 
> complicated it has all become.  I'd be happy if someone stepped 
> forward and volunteered to help or take over the integration.

We hope the interest of community about IPv6 will grow.
Feel free to send comments on the code.

>-------------------------------------------------------------------------
>This SF.net email is sponsored by DB2 Express
>Download DB2 Express C - the FREE version of DB2 express and take
>control of your XML. No limits. Just data. Click to get it now.
>http://sourceforge.net/powerbar/db2/
>
>------------------------------------------------------------------------
>
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>


-- 

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
