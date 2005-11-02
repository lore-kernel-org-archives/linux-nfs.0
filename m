From: CHIKAMA masaki <masaki-c@nict.go.jp>
Subject: Re: Can't write over 100GB to large NFS server (10TB)
Date: Wed, 2 Nov 2005 14:07:54 +0900
Message-ID: <20051102140754.6cde2cea.masaki-c@nict.go.jp>
References: <20051031112056.546d7d7b.masaki-c@nict.go.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXAqu-000409-4Z
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 21:08:00 -0800
Received: from ns1.nict.go.jp ([133.243.3.1])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EXAqs-0006c7-4u
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 21:08:00 -0800
Received: from gw1.nict.go.jp (gw1.nict.go.jp [133.243.18.250])
	by ns1.nict.go.jp  with ESMTP id jA257tjb003387
	for <nfs@lists.sourceforge.net>; Wed, 2 Nov 2005 14:07:55 +0900 (JST)
Received: from gw1.nict.go.jp (localhost [127.0.0.1])
	by gw1.nict.go.jp  with ESMTP id jA257tQ5028313
	for <nfs@lists.sourceforge.net>; Wed, 2 Nov 2005 14:07:55 +0900 (JST)
Received: from mail1.nict.go.jp (mail.nict.go.jp [133.243.18.3])
	by gw1.nict.go.jp  with ESMTP id jA257tfU028310
	for <nfs@lists.sourceforge.net>; Wed, 2 Nov 2005 14:07:55 +0900 (JST)
Received: from mail1.nict.go.jp (localhost [127.0.0.1])
	by localhost.nict.go.jp (Postfix) with ESMTP id 082304305
	for <nfs@lists.sourceforge.net>; Wed,  2 Nov 2005 14:07:55 +0900 (JST)
Received: from nabal.nict.go.jp (unknown [133.243.93.85])
	by mail1.nict.go.jp (Postfix) with SMTP id D1FDA4304
	for <nfs@lists.sourceforge.net>; Wed,  2 Nov 2005 14:07:54 +0900 (JST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20051031112056.546d7d7b.masaki-c@nict.go.jp>
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

Hello all.

There is a 8TB (not 16TB) filesystem limitation in reiserfs3 
and this cause my problem. The Nfs server is not guilty.

 http://marc.theaimsgroup.com/?l=reiserfs&m=112255940804474&w=2

I changed to xfs and problem solved.
Sorry for bothering the list.

Thanks.


On Mon, 31 Oct 2005 11:20:56 +0900
CHIKAMA masaki <masaki-c@nict.go.jp> wrote:

> Hello all.
> 
> I have some trouble with large NFS server.
> I can't write date over 100GB to NFS server.
> 
> Here is my setup.
> 
> NFS server (HOSTA)
>   Fedora Core 3 + update + kernel-2.6.13.4
>   10TB disk. reiserfs3.
> 
> NFS client
>   Fedora Core 3 + update (2.6.12-1.1380_FC3smp)
>   SUSE 9.1 (2.6.12.4)
>   RedHat 7.3 (2.4.25)
> 
> 
> How to reproduce  
> 
> $ df -h
> Filesystem            Size  Used Avail Use% Mounted on
> /dev/mapper/VolGroup00-LogVol00
>                        73G  2.9G   66G   5% /
> /dev/hda1              99M   38M   56M  41% /boot
> none                  248M     0  248M   0% /dev/shm
> HOSTA:/raid/disk1      11T  100G   11T   1% /misc/HOSTA
> 
> $dd if=/dev/zero of=/mis/HOSTA/largefile bs=1024 count=65536
> 65536+0 records in
> 65536+0 records out
> dd: closing output file `largefile': No space left on device
> 
> All three different client produce the same result.
> 
> Writing local filesystem is OK.
> 
> -rw-rw-r--  1 demo demo 15106048 Oct 31 11:08 largefile   (<- NFS write)
> -rw-rw-r--  1 demo demo 67108864 Oct 31 11:11 largefile2  (<- Local write)
> 
> Strangely enough, I have no trouble with 5TB partion(reisefs3) 
> on the HOSTA.
> 
> /dev/mapper/vg0-lvol0
>                       5.1T  2.4T  2.8T  46% /raid/disk0
> /dev/mapper/vg1-lvol0
>                        11T  100G   11T   1% /raid/disk1
> 
> Any help appreciates.
> Thanks.
> 
> 
> -- 
> CHIKAMA Masaki @ NICT
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.
> Get Certified Today * Register for a JBoss Training Course
> Free Certification Exam for All Training Attendees Through End of 2005
> Visit http://www.jboss.com/services/certification for more information
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-- 
CHIKAMA Masaki @ NICT



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
