From: "Lorn Kay" <lorn_kay@hotmail.com>
Subject: Re: Re: NFS as a Cluster File System.
Date: Thu, 09 Jan 2003 22:51:30 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F155FnqdR2xuRoAnbsZ00020983@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f155.law11.hotmail.com ([64.4.17.155] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WlWj-0003Dj-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 14:51:53 -0800
To: alanr@unix.sh
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>NFS V3 and before have problems with "cache coherency".  That is, the 
>different nodes in the cluster are not guaranteed to see the same contents.
>
>I think this is supposed to be fixed in v4.
>
>
>--
>     Alan Robertson <alanr@unix.sh>
>
>"Openness is the foundation and preservative of friendship....  Let me 
>claim from you at all times your undisguised opinions." - William 
>Wilberforce
>

I think this can be resolved with the "noac" mount option (prior to V4).

--K




_________________________________________________________________
MSN 8 helps eliminate e-mail viruses. Get 2 months FREE* 
http://join.msn.com/?page=features/virus



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
