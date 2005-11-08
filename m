From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Errors ...
Date: Tue, 08 Nov 2005 06:35:55 -0800
Message-ID: <1131460555.32482.4.camel@lade.trondhjem.org>
References: <4370AB14.9020203@renatre.org.ar>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZUfS-0007uv-Ra
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:41:46 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZUfR-0002km-5N
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:41:46 -0800
To: Alan Glait <aglait@renatre.org.ar>
In-Reply-To: <4370AB14.9020203@renatre.org.ar>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 2005-11-08 at 10:41 -0300, Alan Glait wrote:
> Hi !
> I have an Fedora core 4 exporting a directory. It have 2.6.13 kernel.
> I mount it on Red Hat Enterprise Linux AS release 3 with 2.4.21-4.ELsmp 
> kernel. In the server, I get "svc: unknown version (0)" everytime. In 
> the client i get :nfsd: last server has exited

That is probably 2.6.13 probing for ACL support on the server. It should
be harmless.

>                                                              nfsd: 
> unexporting all filesystems
>                                                              nfsd: last 
> server has exited
>                                                              nfsd: 
> unexporting all filesystems
>                                                              portmap: 
> server localhost not responding, timed out
> all time.
> There is no problem but sometimes in the client it start to consume a 
> lot of the processors and I cant to stop it. The service stop ok but it 
> doesnt "release the usage" of th precessors ... in a top, a see iowait 
> at 100% or 98% .

Could you explain what you mean by "iowait at 100%"? Normally, iowait is
a process state, (a sleep state actually).

Which process is in this state?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
