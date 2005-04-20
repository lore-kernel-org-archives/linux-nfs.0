From: esqueleto@tusofona.com
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 00:00:52 +0100
Message-ID: <1114038052.4266df245e54e@webmail.tusofona.com>
References: <1114027379.4266b57354785@webmail.tusofona.com> <4266C21D.9030305@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOOBu-0004yK-TG
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 16:01:06 -0700
Received: from [81.92.210.10] (helo=agata.100limite.pt)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOOBt-0004wY-4R
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 16:01:06 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4266C21D.9030305@RedHat.com>
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

esqueleto@tusofona.com wrote:
> > I have a portable computer with FC3. This computer have Wireless and =
Wired
> > network and i have some NFS mount points in my file system.
> >
> > Usualy i want to change throught between the wireless and wired conne=
ction
> and
> > when i do this my mount points became busy.
> Try 'lsof /home/Acropole` to see what process is using
> the filesystem.

This system freeze. Don't give any information.....

> >
> > There is some way to umount NFS mount points after the system loose t=
he
> network?
> not safely...

Why? There is no Network!! Why the NFS mantain the connection? Should the=
 NFS
umount the mount points?


(())
Esqueleto
Odivelas - Portugal

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
