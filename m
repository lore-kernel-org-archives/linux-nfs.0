From: "Greg Bradner" <greg.bradner@gmail.com>
Subject: [NFS] mount problems with Acopia and OpenVZ
Date: Mon, 25 Aug 2008 14:54:59 -0700
Message-ID: <57bc13580808251454l168e68f1g43f6ad137eb68b35@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51691 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157AbYHYVzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2008 17:55:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KXk1l-0003c6-9p
	for linux-nfs@vger.kernel.org; Tue, 26 Aug 2008 07:55:09 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a problem with mount options under an OpenVZ container through
an Acopia.  I don't have the same problem on the master where the
containers live.

I try to mount the file system at 32k wsize/rsize.  It only mounts a 8k.

>From fstab:
acopia01:/ac  /ac  nfs
rw,vers=3,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=2
0 0

After mount:
acopia01:/ac on /ac type nfs
(rw,vers=3,rsize=8192,wsize=8192,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys)


I have looked at an strace of mount and don't see anything.  I have
looked a ethereal dump and don't see anything.

What am I'm missing?  What can I try?

Thanks for any help.


# cat /etc/issue
CentOS release 5.1 (Final)

# uname -ar
Linux  2.6.18-53.1.19.el5.028stab053.14 #1 SMP Thu May 8 16:29:13 MSD
2008 x86_64 x86_64 x86_64 GNU/Linux

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

