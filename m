From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Problems with statd and lockd
Date: Sat, 5 Apr 2003 15:45:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200304051545.43063.bernd-schubert@web.de>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 191nzF-0006ST-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 05:45:38 -0800
To: Philippe =?iso-8859-1?q?Gramoull=E9?= <philippe.gramoulle@mmania.com>,
 NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
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

On Saturday 05 April 2003 01:56, Philippe Gramoullé wrote:
> Hi,
>
> Recently we started to get the following error messages on an Linux NFS
> server, running 2.4.21-pre5 vanilla, Debian unstable
>
>  > statd: server localhost not responding, timed out
>  > nsm_mon_unmon: rpc failed, status=-5
>  > lockd: cannot monitor <Client IP here>
>
> A restart of nfs-kernel-server cleared the problem.
>
> We have filesystems that are exported sync, other are exported async.
>


Hi, 

we also see those messages when we use the rpc.statd from debian packages. I 
think the debian nfs-utils packages got "--enable-secure-statd" as configure 
option. After recompiling the nfs-utils without this option and starting the 
new rpc.statd on the clients, those messages should disappear, even without 
restarting the nfs-server.
(I discovered this odd behaviour by accident.)


Best regards,
	Bernd


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
