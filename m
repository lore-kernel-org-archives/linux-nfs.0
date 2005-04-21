From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Wed, 20 Apr 2005 20:19:43 -0400
Message-ID: <1114042784.17214.11.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOPQW-0001NX-4C
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 17:20:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOPQU-0001dd-Fs
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 17:20:15 -0700
To: esqueleto@tusofona.com
In-Reply-To: <1114038052.4266df245e54e@webmail.tusofona.com>
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

to den 21.04.2005 Klokka 00:00 (+0100) skreiv esqueleto@tusofona.com:
> > > There is some way to umount NFS mount points after the system loose the
> > network?
> > not safely...
> 
> Why? There is no Network!! Why the NFS mantain the connection? Should the NFS
> umount the mount points?
> 

Umm... Perhaps because there is a general consensus among NFS developers
that throwing away people's data, and killing off their processes
without their consent might be a bad thing?

If you want that sort of behaviour, then read all about the "soft" mount
option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
