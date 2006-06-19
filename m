From: Neil Brown <neilb@suse.de>
Subject: Re: Group write not working in 2.6.16.X
Date: Tue, 20 Jun 2006 09:06:21 +1000
Message-ID: <17559.11757.102965.439100@cse.unsw.edu.au>
References: <20060605155427.GQ27961@ohnesorg.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FsSpT-0000Vr-4Q
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 16:06:47 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FsSpR-0002SP-VW
	for nfs@lists.sourceforge.net; Mon, 19 Jun 2006 16:06:47 -0700
To: Dan Ohnesorg <Dan@ohnesorg.cz>
In-Reply-To: message from Dan Ohnesorg on Monday June 5
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

On Monday June 5, Dan@ohnesorg.cz wrote:
> 
> I have found strange problem with nfs after upgrading from kernel 2.6.14 to
> 2.6.16.
> 
> System on both ends is Debian Sarge with all patches. We use user space nfs
> server.
> 
> Problem is, that a file with group write permission is not writable by this
> group, lets have a server called server and client called client, on server
> export directory /data/export
> 
> server# cat /etc/exports
> /data/export              192.168.0.2/255.255.255.255(rw,no_root_squash,sync)
> 
> and mount them on client
> 
> client# mount -t nfs server:/data/export /mnt/data
> 
> than try on client
> 
> client# cd /mnt/data
> client# echo "Hi" > file.txt
> client# chmod g+w file.txt
> client# su - someuser
> client$ cd /mnt/data
> client$ echo "Hi2" >> file.txt
> -su: test: Permission denied

Could you please re-run the experiment with calls to 'groups' and
'ls -l file.text'  and suitable points so that we can see that
someuser really does have group write.

Can you collect a tcpdump trace while this is happening.
e.g.
   tcpdump -w /tmp/trace -s 1500 host SERVER and host CLIENT and port 2049

and compress/attach /tmp/trace.

Thanks,
NeilBrown


> 
> this problem occures only with kernel 2.6.16 on client side, after reboot to
> 2.6.14 the append works great with same configuration. Another important hit
> is, that the problem is only in directory, where the nfs tree is mounted, on
> subdirectories is everythink working properly.
> 
> Is this bug or are oldes kernels buggy and now is the situation corrected?
> 
> cheers
> dan
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
