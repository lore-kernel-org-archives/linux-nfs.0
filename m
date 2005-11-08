From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Errors ...
Date: Tue, 08 Nov 2005 09:53:43 -0500
Message-ID: <4370BBF7.50907@RedHat.com>
References: <4370AB14.9020203@renatre.org.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZUr5-00008V-07
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:53:47 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZUr3-0006MQ-Gp
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 06:53:47 -0800
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



Alan Glait wrote:
> I have an Fedora core 4 exporting a directory. It have 2.6.13 kernel.
> I mount it on Red Hat Enterprise Linux AS release 3 with 2.4.21-4.ELsmp 
> kernel. 
I have to admit... this gave be a bit of a scare...
but this seem to work for me...

> In the server, I get "svc: unknown version (0)" everytime. 
This basically means your server it getting garbage instead
of a valid RPC message...

> In the client i get :nfsd: last server has exited
>                                                             nfsd: 
> unexporting all filesystems
>                                                             nfsd: last 
> server has exited
>                                                             nfsd: 
> unexporting all filesystems
>   
This does not make much sense they are happening on your
client since they happen when you bring down the NFS server.

> portmap: server localhost not responding, timed out
I would guess this means your network is down...


steved.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
