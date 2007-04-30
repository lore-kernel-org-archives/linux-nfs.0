From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Tue, 01 May 2007 00:49:12 +0200
Message-ID: <46367268.5030600@oxeva.fr>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>	<46362BC8.9040305@oxeva.fr>
	<17974.24183.309814.609652@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Kottaridis,  Chris" <chris.kottaridis@windriver.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hiegg-0003rQ-UF
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 15:49:43 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hiegg-0001Z1-Hr
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 15:49:45 -0700
In-Reply-To: <17974.24183.309814.609652@notabene.brown>
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

BTW, there is a bug in the configure script provided in the 
nfs-utils-1.1.0-rc2 package : --without-uuid does't work, but 
--disable-uuid does for excluding libblkid linking.

Gabriel

On 04/30/2007 23:24:07 +0200, Neil Brown <neilb@suse.de> wrote:

> On Monday April 30, gabriel@oxeva.fr wrote:
>> I have this problem too for a long time and already reported it, but 
>> propably forgotten. My rpc.mountd is actually 350MB and continue 
>> growing, with nfs-utils 1.1.0-rc2:
>>
>> # rpc.mountd --version
>> kmountd 1.1.0-rc2
> 
> Is this compiled with libblkid (the default)?
> There is a memory leak in libblkid that was only fixed quite recently
> so unless your libblkid is very new, you should use
>     ./configure --without-uuid
> 
> NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
