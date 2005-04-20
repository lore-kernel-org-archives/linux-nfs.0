From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Wed, 20 Apr 2005 16:57:01 -0400
Message-ID: <4266C21D.9030305@RedHat.com>
References: <1114027379.4266b57354785@webmail.tusofona.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOMFt-00075K-Sp
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:57:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOMFr-0000He-Ds
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:57:05 -0700
To: esqueleto@tusofona.com
In-Reply-To: <1114027379.4266b57354785@webmail.tusofona.com>
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
> I have a portable computer with FC3. This computer have Wireless and Wired
> network and i have some NFS mount points in my file system.
> 
> Usualy i want to change throught between the wireless and wired connection and
> when i do this my mount points became busy.
Try 'lsof /home/Acropole` to see what process is using
the filesystem.

> 
> There is some way to umount NFS mount points after the system loose the network?
not safely...

steved.


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
