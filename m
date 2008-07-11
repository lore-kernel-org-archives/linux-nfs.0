From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Stale NFS file handle error
Date: Fri, 11 Jul 2008 08:50:28 -0400
Message-ID: <48775714.6090107@redhat.com>
References: <48774466.508@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48988 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbYGKMus (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 08:50:48 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KHI5G-0003Ao-3H
	for linux-nfs@vger.kernel.org; Fri, 11 Jul 2008 22:50:46 +1000
In-Reply-To: <48774466.508-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom H wrote:
> Hi,
>
> I have been intermittently seeing a "Stale NFS file handle" error from a 
> Java app we use to resize images and save them to a file on an NFS 
> mounted directory.
>
> An example of the code in Java is;
>
> 	File outputFile = new File(outputDir, (new 
> StringBuilder()).append(filePrefix).append(ifile.getName()).toString());
> 	BufferedImage large = ImageIO.read(inputFile);
> 	BufferedImage scaled = scale(large, width, height);
> 	ImageIO.write(scaled, "jpg", outputFile);
>
> And about once in every 10 thousand writes, it throws the following error;
>
> java.io.IOException: Stale NFS file handle
> 	at java.io.RandomAccessFile.close(RandomAccessFile.java:573)
> 	at 
> javax.imageio.stream.FileImageOutputStream.close(FileImageOutputStream.java:160)
> 	at javax.imageio.ImageIO.write(ImageIO.java:1519)
> 	at com.hz.pagemill.process.ImageScaler.scale(ImageScaler.java:47)
>
> The NFS3 protocol specification defines a Stale File handle error as 
> follows; (http://tools.ietf.org/html/rfc1813)
>
>     NFS3ERR_STALE
>         Invalid file handle. The file handle given in the
>         arguments was invalid. The file referred to by that file
>         handle no longer exists or access to it has been
>         revoked.
>
> The way the code works prevents 2 processes creating the same file, so I 
> am pretty sure that whatever is moving, renaming or deleting the file is 
> not part of the java app.
>
> We are running the default nfs server with RHEL4;
> [root@aspdb01 ~]# modinfo nfsd
> filename:       /lib/modules/2.6.9-55.0.9.ELsmp/kernel/fs/nfsd/nfsd.ko
> license:        GPL
> author:         Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
> depends:        sunrpc,exportfs,lockd,nfs_acl
> vermagic:       2.6.9-55.0.9.ELsmp SMP gcc-3.4
>
> with the following export options;
> [root@aspdb01 ~]# cat /etc/exports
> /myshareZZZ     *(rw,sync,no_root_squash,no_subtree_check)
>
> (I have tried it with, and without no_subtree_check)
>
> I was hoping to get some pointers on debugging the issue.

Are you sure that you don't have two (or more) different NFS
clients working in the same directory?

The ESTALE error usually occurs when a change is made on the
server to something that a client is accessing, perhaps
directly on the server or more commonly, by a different NFS
client.

       ps

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

