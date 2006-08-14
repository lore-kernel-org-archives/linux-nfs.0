From: Neil Brown <neilb@suse.de>
Subject: Re: conflicting options in a single export entry
Date: Mon, 14 Aug 2006 14:54:36 +1000
Message-ID: <17632.524.517556.973817@cse.unsw.edu.au>
References: <1155530309.15273.9.camel@blr-chax.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCUTP-0002Ay-KJ
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 21:54:47 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCUTO-00080e-UW
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 21:54:48 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 5BBF510741
	for <nfs@lists.sourceforge.net>; Mon, 14 Aug 2006 06:54:40 +0200 (CEST)
To: pchakravarthi@novell.com
In-Reply-To: message from Chakravarthi on Monday August 14
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

On Monday August 14, pchakravarthi@novell.com wrote:
> hi all
> 
>    apart from the obvious conflicting options of the kind (rw,ro) and 
>    (sync, async),  what are the sets of other conflicting options, if
> any, 
>    for an export entry ?
> 
>    also, are there requirement dependencies on options such as
>    mentioning opt_1 requires opt_, opt_5 and opt_6.  and so on  ?
> 
>    man exports doesn't give any such info. I wanted to confirm this
>    as i want to complete the LiMaL pluglib for configuring nfs-server.

The only other thing that occurs to be relates to uid squashing.

i.e. if you have 'all_squash', there is no point in root_squash or
no_root_squash, and unless you have ether all_squash or root_squash
there is no point in anonuid or anongid.
Everything else is fairly independent.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
